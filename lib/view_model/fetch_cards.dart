import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert' show json;

import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/model/vocab.dart';

Future<List<VocabWord>> fetchJSONCards(String category) async {
  try {
    // Load the JSON file
    String jsonString = await rootBundle.loadString('assets/json/all_cards2.json');
    final data = json.decode(jsonString);
    final cards = data[category];

    // Convert JSON to list of ImageButton objects
    return List<VocabWord>.from(cards.map((item) => VocabWord.fromJson(item)));

  } catch (error) {
    print("Error loading JSON data: $error");

    return []; // Return an empty list in case of error
  }
}

Future<List<VocabWord>> fetchCards(String category) async {
  final DatabaseService dbService = DatabaseService();

  // Load from Hive first
  List<VocabWord>? localData = dbService.getLocalContent(category);

  if (localData != null) return localData;

  // If Hive data is not available, fetch from Firestore
  await dbService.syncContent();
  return dbService.getLocalContent(category) ?? [];
}