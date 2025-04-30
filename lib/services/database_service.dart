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
import 'package:mozambique_app/view/no_data_screen.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<List> _homeWordBox = Hive.box('home_words'); // Opened as List, not List<HomeWord>
  final Box<List> _vocabWordBox = Hive.box('vocab_words'); // Opened as List, not List<VocabWord>
  final Box<List> _questionBox = Hive.box('questions'); // Opened as List, not List<Question>
  final Box<List> _quizQuestionBox = Hive.box('quiz_questions'); // Opened as List, not List<QuizQuestion>
  final Box<List> _convoBox = Hive.box('conversations'); // Opened as List, not List<Conversation>

  // Initialize the database and check if data exists in Hive
  Future<void> initializeDatabase(BuildContext context) async {
    if (_homeWordBox.isEmpty || _vocabWordBox.isEmpty || _questionBox.isEmpty || _quizQuestionBox.isEmpty) {
      print("Hive database is empty. Syncing with Firestore...");
      await syncContent(context: context);
    } else {
      print("Hive database has data. No need to sync.");
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

  // Show alert dialog for no internet connection
  void _showNoConnectionAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Sync content from Firestore to Hive
  Future<bool> syncContent({BuildContext? context}) async {
    // Check internet connection
    bool isConnected = await checkInternetConnection();

    if (!isConnected) {
      print("No internet connection. Cannot sync data.");

      
      if (context != null) { 
        if (_homeWordBox.isEmpty && _vocabWordBox.isEmpty && _questionBox.isEmpty && _quizQuestionBox.isEmpty) { // If there's no data, show NoDataScreen
          Navigator.pushReplacement( // Navigate to NoDataScreen and remove all previous routes
            context,
            MaterialPageRoute(
              builder: (context) => const NoDataScreen(),
            ),
          );
        } else { // Only show alert if data is already present in Hive
          _showNoConnectionAlert(context);
        }
      }

      return false; // No internet connection
    }

    await _syncHomeWords();
    await _syncVocabWords();
    await _syncQuestionResponse();
    await _syncQuizQuestions();
    await _syncPracConvo();

    //printConvos();
    print("Data synced from Firestore to Hive.");

    return true; // Sync successful
  }

  // Sync Home cards from Firestore to Hive
  Future<void> _syncHomeWords() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('home').get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        List<HomeWord> homeWords = await Future.wait(data['home_cards'].map<Future<HomeWord>>((item) async {
          if (item['imageBase64'] != null) {
            // Decode base64 image if available
            item['imageBase64'] = item['imageBase64'].replaceAll(RegExp(r'^data.*,'), '');
          }
          Uint8List imageBytes = item['imageBase64'] != null ? base64Decode(item['imageBase64']) : await(fetchMedia(item['imagePath']));

          return HomeWord(
            word: item['word'],
            portuguese: item['portuguese'],
            categoryName: item['categoryName'],
            imageBytes: imageBytes,
            imagePath: item['imagePath'],
            type: item['type'],
          );
        }).toList());

        // Store the data in Hive
        await _homeWordBox.put('home_cards', homeWords.cast<dynamic>());
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  // Sync Learn vocab cards from Firestore to Hive
  Future<void> _syncVocabWords() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('categories').get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        for (String category in data.keys) {
          List<VocabWord> vocabWords = await Future.wait(data[category].map<Future<VocabWord>>((item) async {
            if (item['imageBase64'] != null) {
              // Decode base64 image if available
              item['imageBase64'] = item['imageBase64'].replaceAll(RegExp(r'^data.*,'), '');
            }
            if (item['audioBase64'] != null) {
              // Decode base64 audio if available
              item['audioBase64'] = item['audioBase64'].replaceAll(RegExp(r'^data.*,'), '');
            }

            Uint8List imageBytes = item['imageBase64'] != null ? base64Decode(item['imageBase64']) : await(fetchMedia(item['imagePath']));
            Uint8List audioBytes = item['audioBase64'] != null ? base64Decode(item['audioBase64']) : await(fetchMedia(item['audioPath']));

            return VocabWord(
              categoryName: item['categoryName'],
              word: item['word'],
              portuguese: item['portuguese'],
              imageBytes: imageBytes,
              audioBytes: audioBytes,
              imagePath: item['imagePath'],
              audioPath: item['audioPath'],
            );
          }).toList());

          // Store the data in Hive
          await _vocabWordBox.put(category, vocabWords.cast<dynamic>());
        }
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  // Sync Learn conversations from Firestore to Hive
  Future<void> _syncQuestionResponse() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('learnConvo').get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      
        for (String category in data.keys) {
          List<Question> questions = await Future.wait(data[category].map<Future<Question>>((item) async {
            Uint8List audioBytes = await(fetchMedia(item['audioPath']));

            List<Response> responses = []; // Responses list for each question
            for(var j = 0; j < item['responses'].length; j++) {
              Uint8List audioBytesRes = await(fetchMedia(item['responses'][j]['audioPath']));
              
              Response response = Response(
                responseText: item['responses'][j]['responseText'],
                audioPath: item['responses'][j]['audioPath'],
                emotion: item['responses'][j]['emotion'],
                audioBytes: audioBytesRes
              );

              responses.add(response);
            }

            return Question(
              categoryName: category,
              questionText: item['questionText'],
              audioPath: item['audioPath'],
              responses: responses,
              audioBytes: audioBytes
            );
          }).toList());
          
          //Store the data in Hive
          await _questionBox.put(category, questions.cast<dynamic>());
        }
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  // Sync Practice conversations from Firestore to Hive
  Future<void> _syncPracConvo() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('pracConvo').get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        for (String category in data.keys) {
        List<Conversation> convos = [];
        List<ConvoLine> lines = [];
         // log(data[category][0]["imagePath"]);
          String imagePath = data[category][0]["imagePath"];
          //log(imagePath);
          Uint8List imageBytes = await(fetchMedia(imagePath));
          for (int i = 0; i < data[category].length; i++ ) {
            if (i == 0) continue; // Skip the first item as it is the image path
            //log(data[category][i]["msgText"]);
            lines.add(ConvoLine(
              convoText: data[category][i]["msgText"], 
              audioPath: data[category][i]["audioPath"], 
              audioBytes: await(fetchMedia(data[category][i]["audioPath"])))
            );
          }
          convos.add(Conversation(
            categoryName: category, 
            conversationText: lines, 
            imagePath: imagePath, 
            imageBytes: imageBytes)
          );
          //Store the data in Hive
          await _convoBox.put(category, convos);
          printConvo(category);
        }
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  // Sync Practice Quiz questions from Firestore to Hive
  Future<void> _syncQuizQuestions() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('practice_quiz').get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        for (String category in data.keys) {
          List<QuizQuestion> quizQuestions = await Future.wait(data[category].map<Future<QuizQuestion>>((item) async {
            List<QuizAnswer> answers = []; // Answers list for each question

            Uint8List qImageBytes = await(fetchMedia(item['imagePath']));
            Uint8List qAudioBytes = await(fetchMedia(item['audioPath']));

            // for(var j = 0; j < item['answers'].length; j++) {
            //   QuizAnswer answer = QuizAnswer(
            //     answerText: item['answers'][j]['answerText'],
            //     isCorrect: item['answers'][j]['isCorrect'],
            //     audioPath: item['answers'][j]['audioPath']
            //   );

            //   answers.add(answer);
            // }

            answers = await Future.wait(item['answers'].map<Future<QuizAnswer>>((answerItem) async {
              Uint8List ansAudioBytes = await(fetchMedia(answerItem['audioPath']));

              return QuizAnswer(
                answerText: answerItem['answerText'],
                isCorrect: answerItem['isCorrect'],
                audioPath: answerItem['audioPath'],
                audioBytes: ansAudioBytes,
              );
            }).toList());

            return QuizQuestion(
              questionText: item['questionText'],
              imageBytes: qImageBytes,
              audioBytes: qAudioBytes,
              imagePath: item['imagePath'],
              audioPath: item['audioPath'],
              answers: answers
            );
          }).toList());

          // Store the data in Hive
          await _quizQuestionBox.put(category, quizQuestions.cast<dynamic>());
        }
      }
    } catch (err) {
      print('Error syncing data: $err');
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

        print('Category: $key');
        for (VocabWord word in vocabWords) {
          print('Word: ${word.word}, Portuguese: ${word.portuguese}, ImageBytes: ${word.imageBytes}');
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
        log('text: ${l.convoText}, AudioPath: ${l.audioPath}, AudioBytes: ${l.audioBytes}');
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
          log('text: ${l.convoText}, AudioPath: ${l.audioPath}, AudioBytes: ${l.audioBytes}');
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

        print('Category: $key');
        for (QuizQuestion q in quizQuestions) {
          print('Question: ${q.questionText}, ImagePath: ${q.imagePath}');
          for (QuizAnswer a in q.answers) {
            print('Answer - text: ${a.answerText}, isCorrect: ${a.isCorrect}, AudioPath: ${a.audioPath}');
          }
        }
      }
    }
  }
}




