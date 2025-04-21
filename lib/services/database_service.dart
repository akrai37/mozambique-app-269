import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/model/question.dart';
import 'package:mozambique_app/model/vocab.dart';
import 'package:mozambique_app/view/no_data_screen.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<List> _homeWordBox = Hive.box('home_words'); // Opened as List, not List<HomeWord>
  final Box<List> _vocabWordBox = Hive.box('vocab_words'); // Opened as List, not List<VocabWord>
  final Box<List> _questionWordBox = Hive.box('questions');
  final Box<List> _responseWordBox = Hive.box('responses');

  // Initialize the database and check if data exists in Hive
  Future<void> initializeDatabase(BuildContext context) async {
    if (_homeWordBox.isEmpty || _vocabWordBox.isEmpty) {
      print("Hive database is empty. Syncing with Firestore...");
      await syncContent(context: context);
    } else {
      print("Hive database has data. No need to sync.");
    }
  }

  Future<Uint8List> fetchMedia(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load media from $url');
    }
  }

  // Check internet connectivity
  Future<bool> _checkInternetConnection() async {
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
  Future<void> syncContent({BuildContext? context}) async {
    // Check internet connection
    bool isConnected = await _checkInternetConnection();

    if (!isConnected) {
      print("No internet connection. Cannot sync data.");

      
      if (context != null) { 
        if (_homeWordBox.isEmpty && _vocabWordBox.isEmpty && _questionWordBox.isEmpty && _responseWordBox.isEmpty) { // If there's no data, show NoDataScreen
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

      return;
    }

    await _syncHomeWords();
    await _syncVocabWords();
    await _syncQuestionResponse();

    print("Data synced from Firestore to Hive.");
  }

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

  Future<void> _syncQuestionResponse() async {
    try{
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('categories').get();
      if(snapshot.exists){
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      
        for (String category in data.keys) {
          log(category); //should be all
      //     List<Question> vocabWords = await Future.wait(data[category].map<Future<VocabWord>>((item) async {
      //       if (item['imageBase64'] != null) {
      //         // Decode base64 image if available
      //         item['imageBase64'] = item['imageBase64'].replaceAll(RegExp(r'^data.*,'), '');
      //       }
      //       if (item['audioBase64'] != null) {
      //         // Decode base64 audio if available
      //         item['audioBase64'] = item['audioBase64'].replaceAll(RegExp(r'^data.*,'), '');
      //       }

      //       Uint8List imageBytes = item['imageBase64'] != null ? base64Decode(item['imageBase64']) : await(fetchMedia(item['imagePath']));
      //       Uint8List audioBytes = item['audioBase64'] != null ? base64Decode(item['audioBase64']) : await(fetchMedia(item['audioPath']));

      //     //   return Question(
      //     //     categoryName: item['categoryName'],
      //     //     word: item['word'],
      //     //     portuguese: item['portuguese'],
      //     //     imageBytes: imageBytes,
      //     //     audioBytes: audioBytes,
      //     //     imagePath: item['imagePath'],
      //     //     audioPath: item['audioPath'],
      //     //   );
      //     // }).toList());
          
      //     // Store the data in Hive
      //     //await _vocabWordBox.put(category, vocabWords.cast<dynamic>());
        }
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

// ------------- FETCHING DATA FROM HIVE -----------//
  List<HomeWord>? getHomeWords() {
    List<dynamic>? rawList = _homeWordBox.get('home_cards');

    if (rawList != null) {
      return rawList.cast<HomeWord>(); // explicitly cast to List<HomeWord>
    }

    return null; // no data found for the category
  }

  List<VocabWord>? getVocabWords(String category) {
    List<dynamic>? rawList = _vocabWordBox.get(category);

    if (rawList != null) {
      return rawList.cast<VocabWord>(); // explicitly cast to List<VocabWord>
    }

    return null; // no data found for the category
  }

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

  List<Question>? getQuestion(String category) {}
}


