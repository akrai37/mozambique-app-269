import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mozambique_app/model/conversation.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/model/question.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/model/vocab.dart';
import 'package:mozambique_app/view/no_connection_screen.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<List> _homeWordBox = Hive.box('home_words'); // Opened as List, not List<HomeWord>
  final Box<List> _vocabWordBox = Hive.box('vocab_words'); // Opened as List, not List<VocabWord>
  final Box<List> _questionBox = Hive.box('questions'); // Opened as List, not List<Question>
  final Box<List> _quizQuestionBox = Hive.box('quiz_questions'); // Opened as List, not List<QuizQuestion>
  final Box<List> _convoBox = Hive.box('conversations'); // Opened as List, not List<Conversation>

  // Initialize the database and check if data exists in Hive
  Future<void> initializeDatabase(BuildContext context) async {
    if (_homeWordBox.isEmpty || _vocabWordBox.isEmpty || _questionBox.isEmpty || _quizQuestionBox.isEmpty || _convoBox.isEmpty) {
      log("Hive database is empty. Syncing with Firestore...");
      await syncContent(context: context);
    } else {
      log("Hive database has data. No need to sync.");
    }
  }

  // Fetch media (image/audio) from a URL
  Future<Uint8List> fetchMedia(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load media from $url');
    }
  }

  // Check internet connectivity
  Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult[0] == ConnectivityResult.none) {
      return false;
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    }
  }

  // Sync content from Firestore to Hive
  Future<bool> syncContent({
    BuildContext? context,
    void Function(double progress)? onProgress,
  }) async {
    // Check internet connection
    bool isConnected = await checkInternetConnection();

    if (!isConnected) {
      log("No internet connection. Cannot sync data.");
      
      if (context != null) { 
        Navigator.push( // Navigate to NoConnectionScreen
          context,
          MaterialPageRoute(
            builder: (context) => NoConnectionScreen( // Check if there's content in Hive
              hasContent: !(_homeWordBox.isEmpty && _vocabWordBox.isEmpty && _questionBox.isEmpty && _quizQuestionBox.isEmpty),
            ),
          ),
        );
      }

      return false; // No internet connection
    }

    const totalSteps = 5; // Total number of steps in the sync process
    int completedSteps = 0; // Current step in the sync process

    void onStepCompleted() {
      completedSteps++;
      onProgress?.call(completedSteps / totalSteps); // Update progress after each step
    }

    await Future.wait([
      _syncHomeWords(onStepCompleted),
      _syncVocabWords(onStepCompleted),
      _syncQuestionResponse(onStepCompleted),
      _syncQuizQuestions(onStepCompleted),
      _syncPracConvo(onStepCompleted),
    ]);

    log("Data synced from Firestore to Hive.");
    return true; // Sync successful
  }

  // Sync Home cards from Firestore to Hive
  Future<void> _syncHomeWords(void Function() onStepCompleted) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('home').get();

      if (!snapshot.exists) return; // If the document doesn't exist

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      // Map each item to futures
      List<Future<HomeWord>> homeWordFutures = (data['home_cards'] as List).map<Future<HomeWord>>((item) async {
        // Clean base64 strings if available
        String? base64Image = item['imageBase64']?.replaceAll(RegExp(r'^data.*,'), '');

        // Set up image futures in parallel
        Future<Uint8List> imageFuture = base64Image != null
          ? Future.value(base64Decode(base64Image))
          : fetchMedia(item['imagePath']);

        // Await the image future
        Uint8List imageBytes = await imageFuture;

        return HomeWord(
          word: item['word'],
          portuguese: item['portuguese'],
          categoryName: item['categoryName'],
          imageBytes: imageBytes,
          imagePath: item['imagePath'],
          type: item['type'],
        );
      }).toList();

      // Wait for all home words to be fetched
      List<HomeWord> homeWords = await Future.wait(homeWordFutures);

      // Store the data in Hive
      await _homeWordBox.put('home_cards', homeWords.cast<dynamic>());
    } catch (err) {
      log('Error syncing data: $err');
    } finally {
      onStepCompleted(); // Call the completion function after syncing
    }
  }

  // Sync Learn vocab cards from Firestore to Hive
  Future<void> _syncVocabWords(void Function() onStepCompleted) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('categories').get();

      if (!snapshot.exists) return; // If the document doesn't exist

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      for (String category in data.keys) {
        // Map each item to futures
        List<Future<VocabWord>> vocabWordFutures = (data[category] as List).map<Future<VocabWord>>((item) async {
          // Clean base64 strings if available
          String? base64Image = item['imageBase64']?.replaceAll(RegExp(r'^data.*,'), '');
          String? base64Audio = item['audioBase64']?.replaceAll(RegExp(r'^data.*,'), '');

          // Set up both futures in parallel
          Future<Uint8List> imageFuture = base64Image != null
            ? Future.value(base64Decode(base64Image))
            : fetchMedia(item['imagePath']);

          Future<Uint8List> audioFuture = base64Audio != null
            ? Future.value(base64Decode(base64Audio))
            : fetchMedia(item['audioPath']);

          // Await both futures in parallel
          final results = await Future.wait([imageFuture, audioFuture]);
          Uint8List imageBytes = results[0];
          Uint8List audioBytes = results[1];

          return VocabWord(
            categoryName: item['categoryName'],
            word: item['word'],
            portuguese: item['portuguese'],
            imageBytes: imageBytes,
            audioBytes: audioBytes,
            imagePath: item['imagePath'],
            audioPath: item['audioPath'],
          );
        }).toList();

        // Wait for all vocab words to be fetched
        List<VocabWord> vocabWords = await Future.wait(vocabWordFutures);

        // Store the data in Hive
        await _vocabWordBox.put(category, vocabWords.cast<dynamic>());
      }
    } catch (err) {
      log('Error syncing data: $err');
    } finally {
      onStepCompleted(); // Call the completion function after syncing
    }
  }

  // Sync Learn conversations from Firestore to Hive
  Future<void> _syncQuestionResponse(void Function() onStepCompleted) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('learnConvo').get();

      if (!snapshot.exists) return; // If the document doesn't exist

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    
      for (String category in data.keys) {
        List<Future<Question>> questionFutures = (data[category] as List).map<Future<Question>>((item) async {
          Future<Uint8List> questionAudioFuture = fetchMedia(item['audioPath']);

          // Prepare futures for all responses in parallel
          List<Future<Response>> responseFutures = (item['responses'] as List).map<Future<Response>>((responseItem) async {
            Future<Uint8List> responseAudioFuture = fetchMedia(responseItem['audioPath']);

            // Await the audio future for each response
            Uint8List responseAudioBytes = await responseAudioFuture;

            return Response(
              responseText: responseItem['responseText'],
              audioPath: responseItem['audioPath'],
              emotion: responseItem['emotion'],
              audioBytes: responseAudioBytes,
            );
          }).toList();

          final results = await Future.wait([questionAudioFuture, ...responseFutures]);
          final Uint8List questionAudioBytes = results[0] as Uint8List; // Audio bytes for the question
          final List<Response> responses = results.sublist(1).cast<Response>(); // Responses list

          return Question(
            categoryName: category,
            questionText: item['questionText'],
            audioPath: item['audioPath'],
            responses: responses,
            audioBytes: questionAudioBytes
          );
        }).toList();

        final List<Question> questions = await Future.wait(questionFutures);
        
        //Store the data in Hive
        await _questionBox.put(category, questions.cast<dynamic>());
      }
    } catch (err) {
      log('Error syncing data: $err');
    } finally {
      onStepCompleted(); // Call the completion function after syncing
    }
  }

  // Sync Practice conversations from Firestore to Hive
  Future<void> _syncPracConvo(void Function() onStepCompleted) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('pracConvo').get();

      if (!snapshot.exists) return; // If the document doesn't exist

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      for (String category in data.keys) {
        final convoData = data[category] as List<dynamic>;
        if (convoData.isEmpty) continue; // Skip if no data for the category

        String imagePath = convoData[0]["imagePath"];
        Future<Uint8List> imageBytesFuture = fetchMedia(imagePath);

        List<Future<ConvoLine>> lineFutures = convoData.skip(1).map<Future<ConvoLine>>((lineItem) async {
          Uint8List audioBytes = await fetchMedia(lineItem["audioPath"]);

          return ConvoLine(
            convoText: lineItem["msgText"],
            audioPath: lineItem["audioPath"],
            audioBytes: audioBytes,
          );
        }).toList();

        final results = await Future.wait([imageBytesFuture, ...lineFutures]);
        final Uint8List imageBytes = results[0] as Uint8List; // Image bytes for the conversation
        final convoLines = results.sublist(1).cast<ConvoLine>(); // Lines list

        final Conversation conversation = Conversation(
          categoryName: category,
          imagePath: imagePath,
          imageBytes: imageBytes,
          conversationText: convoLines,
        );

        //Store the data in Hive
        await _convoBox.put(category, [conversation]);
      }
    } catch (err) {
      log('Error syncing data: $err');
    } finally {
      onStepCompleted(); // Call the completion function after syncing
    }
  }

  // Sync Practice Quiz questions from Firestore to Hive
  Future<void> _syncQuizQuestions(void Function() onStepCompleted) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('practice_quiz').get();

      if (!snapshot.exists) return; // If the document doesn't exist

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      for (String category in data.keys) {
        List<Future<QuizQuestion>> quizQuestionFutures = (data[category] as List).map<Future<QuizQuestion>>((item) async {
          List<Future<QuizAnswer>> answersFutures = []; // Answers list for each question

          Future<Uint8List> qImageFuture = fetchMedia(item['imagePath']);
          Future<Uint8List> qAudioFuture = fetchMedia(item['audioPath']);

          answersFutures = (item['answers'] as List).map<Future<QuizAnswer>>((answerItem) async {
            Future<Uint8List> ansAudioFuture = fetchMedia(answerItem['audioPath']);

            // Fetch audio bytes for each answer
            Uint8List ansAudioBytes = await ansAudioFuture;

            return QuizAnswer(
              answerText: answerItem['answerText'],
              isCorrect: answerItem['isCorrect'],
              audioPath: answerItem['audioPath'],
              audioBytes: ansAudioBytes,
            );
          }).toList();

          // Await both futures in parallel
          final results = await Future.wait([qImageFuture, qAudioFuture]);
          Uint8List qImageBytes = results[0];
          Uint8List qAudioBytes = results[1];

          // Wait for all answers to be fetched
          List<QuizAnswer> answers = await Future.wait(answersFutures);

          return QuizQuestion(
            questionText: item['questionText'],
            imageBytes: qImageBytes,
            audioBytes: qAudioBytes,
            imagePath: item['imagePath'],
            audioPath: item['audioPath'],
            answers: answers
          );
        }).toList();

        // Wait for all quiz questions to be fetched
        List<QuizQuestion> quizQuestions = await Future.wait(quizQuestionFutures);

        // Store the data in Hive
        await _quizQuestionBox.put(category, quizQuestions.cast<dynamic>());
      }
    } catch (err) {
      log('Error syncing data: $err');
    } finally {
      onStepCompleted(); // Call the completion function after syncing
    }
  }

// ------------- FETCHING DATA FROM HIVE -----------//

  // Fetch Home cards from Hive
  List<HomeWord>? getHomeWords() {
    List<dynamic>? rawList = _homeWordBox.get('home_cards');

    if (rawList != null) {
      return rawList.cast<HomeWord>(); // explicitly cast to List<HomeWord>
    }

    return null; // no data found for the category
  }

  // Fetch Vocab cards from Hive using a specified category
  List<VocabWord>? getVocabWords(String category) {
    List<dynamic>? rawList = _vocabWordBox.get(category);

    if (rawList != null) {
      return rawList.cast<VocabWord>(); // explicitly cast to List<VocabWord>
    }

    return null; // no data found for the category
  }

  // Fetch all vocab words from Hive
  Map<String, List<VocabWord>> getAllVocabWords() {
    Map<String, List<VocabWord>> allData = {};

    List<String> keys = _vocabWordBox.keys.cast<String>().toList();
    for (String key in keys) {
      List<dynamic>? words = _vocabWordBox.get(key);

      if (words != null) {
        allData[key] = words.cast<VocabWord>(); // Cast to List<VocabWord>
      }
    }

    return allData;
  }

  // Fetch all Portuguese words from Hive
  Map<String, List<String>> getAllPortugueseWords() {
    Map<String, List<String>> allData = {};

    List<String> keys = _vocabWordBox.keys.cast<String>().toList();
    for (String key in keys) {
      List<dynamic>? words = _vocabWordBox.get(key);

      if (words != null) {
        allData[key] = words.map((word) => word.portuguese).cast<String>().toList(); // Cast to List<String>
      }
    }

    return allData;
  }

  // For debugging purposes: Print all vocab words in the box
  void printAllVocabWords() {
    List<String> keys = _vocabWordBox.keys.cast<String>().toList();
    for (String key in keys) {
      List<dynamic>? words = _vocabWordBox.get(key);

      if (words != null) {
        List<VocabWord> vocabWords = words.cast<VocabWord>(); // Cast to List<VocabWord>

        log('Category: $key');
        for (VocabWord word in vocabWords) {
          log('Word: ${word.word}, Portuguese: ${word.portuguese}, ImageBytes: ${word.imageBytes}');
        }
      }
    }
  }

  // Fetch Learn conversations from Hive using a specified category
  List<Question>? getQuestion(String category) {
    List<dynamic>? rawList = _questionBox.get(category);

    if (rawList != null) {
      return rawList.cast<Question>(); // explicitly cast to List<VocabWord>
    }

    return null; // no data found for the category
  }

  // For debugging purposes: Print all Learn conversations in the box
  void printAllQuestions() {
    List<String> keys = _questionBox.keys.cast<String>().toList();
    log("printing questions--");
    log('${_questionBox.isEmpty}');

    for (String key in keys) {
      log(key);
      List<dynamic>? questions = _questionBox.get(key);

      if (questions != null) {
        List<Question> questionS = questions.cast<Question>();

        log('Category: $key');

        for (Question q in questionS) {
          log('text: ${q.questionText}, AudioPath: ${q.audioPath}');
          
          for (Response r in q.responses){
            log('Response - text: ${r.responseText}, AudioPath: ${r.audioPath}, emotion: ${r.emotion}');
          }
        }
      }
    }
  }

  // Fetch Practice conversations from Hive using a specified category
  List<Conversation>? getConvo(String category) {
    List<dynamic>? rawList = _convoBox.get(category);

    if (rawList != null) {
      return rawList.cast<Conversation>();
    }

    return null; // no data found for the category
  }

  bool hasCategoryLearn(String category){
    return _vocabWordBox.containsKey(category) || _questionBox.containsKey(category);
  }
  bool hasCategoryPractice(String category) { // Check if the category exists in either the Practice quiz or conversation boxes
    return _quizQuestionBox.containsKey(category) || _convoBox.containsKey(category);
  }

  bool hasCategoryPracticeConvo(String category) { // Check if the category exists in the Practice conversation box
    return _convoBox.containsKey(category);
  }

  bool hasCategoryPracticeQuiz(String category) { // Check if the category exists in the Practice quiz box
    return _quizQuestionBox.containsKey(category);
  }

  // Fetch Practice Quiz questions from Hive using a specified category
  List<QuizQuestion>? getQuizQuestions(String category) {
    List<dynamic>? rawList = _quizQuestionBox.get(category);

    if (rawList != null) {
      return rawList.cast<QuizQuestion>(); // explicitly cast to List<VocabWord>
    }

    return null; // no data found for the category
  }

  // For debugging purposes: Print all Practice conversations from a specified category
  void printConvo(String category) {
    List<Conversation>? convo = getConvo(category);

    if (convo != null) {
      log('Category: category');
      log('Image: ${convo[0].imagePath}');
      for (ConvoLine l in convo[0].conversationText) {
        log('text: ${l.convoText}, AudioPath: ${l.audioPath}');
      }
    }
  }

  // For debugging purposes: Print all Practice conversations in the box
  void printConvos() {
    List<String> keys = _convoBox.keys.cast<String>().toList();
    
    log("printing practice conversations--");
    log('is empty? ${_convoBox.isEmpty}');

    for (String key in keys) {
      log(key);
      List<dynamic>? convoList = _convoBox.get(key);

      if (convoList != null) {
        List<Conversation> convo = convoList.cast<Conversation>(); 
        log('Category: $key');
        log('Image: ${convo[0].imagePath}');
        for (ConvoLine l in convo[0].conversationText) {
          log('text: ${l.convoText}, AudioPath: ${l.audioPath}');
        }
      }
    }
  }

  // For debugging purposes: Print all Practice Quiz questions in the box
  void printAllQuizQuestions() {
    List<String> keys = _quizQuestionBox.keys.cast<String>().toList();
    for (String key in keys) {
      List<dynamic>? questions = _quizQuestionBox.get(key);

      if (questions != null) {
        List<QuizQuestion> quizQuestions = questions.cast<QuizQuestion>(); // Cast to List<QuizQuestion>

        log('Category: $key');
        for (QuizQuestion q in quizQuestions) {
          log('Question: ${q.questionText}, ImagePath: ${q.imagePath}');
          for (QuizAnswer a in q.answers) {
            log('Answer - text: ${a.answerText}, isCorrect: ${a.isCorrect}, AudioPath: ${a.audioPath}');
          }
        }
      }
    }
  }
}