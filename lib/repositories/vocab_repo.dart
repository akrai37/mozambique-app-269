import 'package:hive/hive.dart';
import 'package:mozambique_app/model/vocab.dart';

/*Class: Vocab Repository
  Works with  
*/

class VocabRepository {
  final Box<VocabWord> _vocabBox = Hive.box<VocabWord>('vocab_words'); 

  //for conflict detection for syncing
  List<VocabWord> getAllVocab() {
    return _vocabBox.values.toList();
  }

  List<VocabWord> getVocabOfCategory(String catName) {
    return _vocabBox.values.where((vocab)=>vocab.categoryName == catName).toList();
  }

  //to use for conflict resolution for syncing
  void addVocab(VocabWord vocab) {
    _vocabBox.put(vocab.word, vocab);
  }

  void deleteVocab(String vocab) {
    _vocabBox.delete(vocab);
  }
}