import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:mozambique_app/model/vocab.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<List> _box = Hive.box('vocab_words'); // Opened as List, not List<VocabWord>

  // Initialize the database and check if data exists in Hive
  Future<void> initializeDatabase() async {
    if (_box.isEmpty) {
      print("Hive database is empty. Syncing with Firestore...");
      await syncContent();
    } else {
      print("Hive database has data. No need to sync.");
    }
  }

  // Sync content from Firestore to Hive
  Future<void> syncContent() async {
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
          await _box.put(category, vocabWords.cast<dynamic>());
        }

        print('Data synced successfully!');
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  // Fetch content from Hive
  List<VocabWord>? getLocalContent(String category) {
    List<dynamic>? rawList = _box.get(category);

    if (rawList != null) {
      return rawList.cast<VocabWord>(); // explicitly cast to List<VocabWord>
    }

    return null; // no data found for the category
  }

  // For debugging purposes: Print all data in the box
  void printAllData() {
    List<String> keys = _box.keys.cast<String>().toList();
    for (String key in keys) {
      List<dynamic>? words = _box.get(key);

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