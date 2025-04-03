import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/model/vocab.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<List> _homeWordBox = Hive.box('home_words'); // Opened as List, not List<HomeWord>
  final Box<List> _vocabWordBox = Hive.box('vocab_words'); // Opened as List, not List<VocabWord>

  // Initialize the database and check if data exists in Hive
  Future<void> initializeDatabase() async {
    if (_homeWordBox.isEmpty || _vocabWordBox.isEmpty) {
      print("Hive database is empty. Syncing with Firestore...");
      await syncContent();
    } else {
      print("Hive database has data. No need to sync.");
    }
  }

  // Sync content from Firestore to Hive
  Future<void> syncContent() async {
    await _syncHomeWords();
    await _syncVocabWords();

    print("Data synced from Firestore to Hive.");
  }

  Future<void> _syncHomeWords() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('cards').doc('home').get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        List<HomeWord> homeWords = data['home_cards'].map<HomeWord>((item) {
          return HomeWord(
            word: item['word'],
            portuguese: item['portuguese'],
            categoryName: item['categoryName'],
            imagePath: item['imagePath'],
            type: item['type'],
          );
        }).toList();

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
          List<VocabWord> vocabWords = data[category].map<VocabWord>((item) {
            return VocabWord(
              categoryName: item['categoryName'],
              word: item['word'],
              portuguese: item['portuguese'],
              imagePath: item['imagePath'],
              audioPath: item['audioPath'],
            );
          }).toList();

          // Store the data in Hive
          await _vocabWordBox.put(category, vocabWords.cast<dynamic>());
        }
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  // Fetch data from Hive

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

  // For debugging purposes: Print all vocab words in the box
  void printAllVocabWords() {
    List<String> keys = _vocabWordBox.keys.cast<String>().toList();
    for (String key in keys) {
      List<dynamic>? words = _vocabWordBox.get(key);

      if (words != null) {
        List<VocabWord> vocabWords = words.cast<VocabWord>(); // Cast to List<VocabWord>

        print('Category: $key');
        for (VocabWord word in vocabWords) {
          print('Word: ${word.word}, Portuguese: ${word.portuguese}');
        }
      }
    }
  }
}