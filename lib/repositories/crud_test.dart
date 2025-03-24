import '../models/vocab.dart';
import 'package:hive/hive.dart';
import 'dart:developer';

Future<void> performCrudOperations(Box<VocabWord> box) async {
  await box.delete("Vermehlo");
  log("Starting CRUD operations...");

   //READ - Fetch all words
  var words = box.values.toList();
  log("All Words: ${words.map((w) => w.word).toList()}");

  //CREATE - Add a new vocab word
  var word1 = VocabWord(1, "Green", "Vermehlo", "lib/assets/images/colors/Red.png", "lib/assets/audio/colors/red.mp3");
  await box.put(word1.word, word1);
  log("Created: ${word1.word} -  ${word1.portuguese} ");

  var word2 = VocabWord(1, "Red", "Verde", "lib/assets/images/colors/Red.png", "lib/assets/audio/colors/red.mp3");
  await box.put(word2.word, word2);
  log("Created: ${word2.word} -  ${word2.portuguese}  ");

  //READ - Fetch all words
  words = box.values.toList();
  log("Words: ${words.map((w) => w.word).toList()}, Translations: ${words.map((w) => w.portuguese).toList()}");

  //UPDATE - Modify a word
  var updatedWord = VocabWord(1, "Green", "Verde", "lib/assets/images/colors/Green.png", "lib/assets/audio/colors/Green.mp3");
  await box.put(updatedWord.word, updatedWord);
  log("Updated: ${updatedWord.word} - ${updatedWord.portuguese}");

  var updatedWord2 = VocabWord(1, "Red", "Vermehlo", "lib/assets/images/colors/Red.png", "lib/assets/audio/colors/red.mp3");
  await box.put(updatedWord2.word, updatedWord2);
  log("Updated: ${updatedWord2.word} - ${updatedWord2.portuguese}");

  //READ - Fetch all words
  words = box.values.toList();
  words = box.values.toList();
  log("Words: ${words.map((w) => w.word).toList()}, Translations: ${words.map((w) => w.portuguese).toList()}");

  //DELETE - Remove a word
  await box.delete("Green");
  await box.delete("Red");
  log("Deleted Words: Green, Red");

  // Confirm Deletion
  log("Remaining Words: ${box.values.map((w) => w.word).toList()}");
}