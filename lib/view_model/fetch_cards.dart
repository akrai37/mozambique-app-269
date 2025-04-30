import 'package:mozambique_app/model/conversation.dart';
import 'package:mozambique_app/model/question.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/model/vocab.dart';

Future<List<HomeWord>> fetchHomeCards({String type = 'learn'}) async {
  final DatabaseService dbService = DatabaseService();

  // Load from Hive first
  List<HomeWord>? localData = dbService.getHomeWords();

  if (localData != null && localData.isNotEmpty) return localData;

  // If Hive data is not available, fetch from Firestore
  await dbService.syncContent();
  return dbService.getHomeWords() ?? [];
}

// Fetch Vocab cards from Hive or Firestore using the category
Future<List<VocabWord>> fetchVocabCards(String category) async {
  final DatabaseService dbService = DatabaseService();

  // Load from Hive first
  List<VocabWord>? localData = dbService.getVocabWords(category);

  if (localData != null && localData.isNotEmpty) return localData;

  // If Hive data is not available, fetch from Firestore
  await dbService.syncContent();
  return dbService.getVocabWords(category) ?? [];
}

// Fetch Learn conversations from Hive or Firestore using the category
Future<List<Question>> fetchQuestionResponse(String category) async {
  final DatabaseService dbService = DatabaseService();

  // Load from Hive first
  List<Question>? localData = dbService.getQuestion(category);

  if (localData != null && localData.isNotEmpty) return localData;

  // If Hive data is not available, fetch from Firestore
  await dbService.syncContent();
  return dbService.getQuestion(category) ?? [];
}

Future<List<Conversation>> fetchPracConvo(String category) async {
  final DatabaseService dbService = DatabaseService();

  // Load from Hive first
  List<Conversation>? localData = dbService.getConvo(category);
  //dbService.printConvo(category);

  if (localData != null) return localData;

  // If Hive data is not available, fetch from Firestore
  await dbService.syncContent();
  return dbService.getConvo(category) ?? [];
}

// Fetch Practice Quiz questions from Hive or Firestore using the category
Future<List<QuizQuestion>> fetchQuizQuestions(String category) async {
  final DatabaseService dbService = DatabaseService();

  // Load from Hive first
  List<QuizQuestion>? localData = dbService.getQuizQuestions(category);

  if (localData != null && localData.isNotEmpty) return localData;

  // If Hive data is not available, fetch from Firestore
  await dbService.syncContent();
  return dbService.getQuizQuestions(category) ?? [];
}

/*
Future<List<VocabWord>> fetchJSONVocabCards(String category) async {
  try {
    // Load the JSON file
    String jsonString = await rootBundle.loadString('assets/json/vocab_words.json');
    final data = json.decode(jsonString);
    final cards = data[category];

    // Convert JSON to list of ImageButton objects
    return List<VocabWord>.from(cards.map((item) => VocabWord.fromJson(item)));

  } catch (error) {
    print("Error loading JSON data: $error");

    return []; // Return an empty list in case of error
  }
}
*/