import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert' show json;

import 'package:mozambique_app/model/image_button.dart';

Future<List<ImageButton>> fetchCards(String tag) async {
  try {
    // Load the JSON file
    String jsonString = await rootBundle.loadString('assets/json/all_cards.json');
    final data = json.decode(jsonString);
    final cards = data[tag];

    // Convert JSON to list of ImageButton objects
    return List<ImageButton>.from(cards.map((item) => ImageButton.fromJson(item)));

  } catch (error) {
    print("Error loading JSON data: $error");

    return []; // Return an empty list in case of error
  }
}