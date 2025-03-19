import '../models/vocab.dart';
import 'package:hive/hive.dart';
import 'dart:developer';

Future<void> performCrudOperations(Box<VocabWord> box) async {
  log("Starting CRUD operations...");

  //CREATE - Add a new vocab word
  var word1 = VocabWord(1, "green", "Vermehlo", "lib/assets/images/colors/Red.png", "lib/assets/audio/colors/red.mp3");
  await box.put(word1.word, word1);
  log("Created: ${word1.word}");

  //READ - Fetch all words
  var words = box.values.toList();
  log("All Words: ${words.map((w) => w.word).toList()}");

  //UPDATE - Modify a word
  var updatedWord = VocabWord(1, "Red", "Vermehlo", "lib/assets/images/colors/Red.png", "lib/assets/audio/colors/red.mp3");
  await box.put(updatedWord.word, updatedWord);
  log("Updated: ${updatedWord.word} - ${updatedWord.portuguese}");

  //DELETE - Remove a word
  await box.delete(1);
  log("Deleted Word 1");

  // Confirm Deletion
  log("Remaining Words: ${box.values.map((w) => w.word).toList()}");
}