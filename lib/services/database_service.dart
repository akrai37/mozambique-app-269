import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import 'package:mozambique_app/model/vocab.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<List<VocabWord>> _box = Hive.box('vocab_words');

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
          await _box.put(category, vocabWords);
        }

        print('Data synced successfully!');
      }
    } catch (err) {
      print('Error syncing data: $err');
    }
  }

  List<VocabWord>? getLocalContent(String category) {
    return _box.get(category)?.cast<VocabWord>();
  }

  // For debugging purposes: Print all data in the box
  void printAllData() {
    List<String> keys = _box.keys.cast<String>().toList();
    for (String key in keys) {
      List<VocabWord>? words = _box.get(key);
      if (words != null) {
        print('Category: $key');
        for (VocabWord word in words) {
          print('Word: ${word.word}, Portuguese: ${word.portuguese}');
        }
      }
    }
  }
}