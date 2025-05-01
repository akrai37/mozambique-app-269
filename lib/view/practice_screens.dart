import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view/learn_card.dart';
import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/model/vocab.dart';

class PracticeScreens extends StatefulWidget {
  final String title;
  final String tag;

  const PracticeScreens({
    super.key,
    required this.title,
    required this.tag,
  });

  @override
  State<PracticeScreens> createState() => _PracticeScreensState();
}

class _PracticeScreensState extends State<PracticeScreens> {
  late List<VocabWord> _imageButtons = [];
  late Future<void> _loadingFuture;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    List<VocabWord>? localData = _databaseService.getVocabWords(widget.tag);

    /* // This fetches from the local JSON file
    try {
      _imageButtons = await fetchJSONVocabCards(widget.tag);

      // Preload images
      for (var imageButton in _imageButtons) {
        await precacheImage(AssetImage(imageButton.img), context);
      }
    } catch (error) {
      log("Error loading JSON data: $error");
    }
    */

    // This fetches from the local Hive database
    try {
      if (localData != null) {
        _imageButtons = await fetchVocabCards(widget.tag);

        // Preload images
        for (VocabWord imageButton in _imageButtons) {
          await precacheImage(AssetImage(imageButton.imagePath), context);
        }
      }
    } catch (error) {
      log("Error loading data from Hive: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            // Show a loading indicator while waiting for images to load
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Once the images are loaded, build the UI
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    const Text(
                      'Practice Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE84C3D),
                      ),
                    ),
                    Expanded( // ensures the TextField takes up the remaining space
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF95A5A5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF95A5A5),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(
                              color: Color(0xFF2D3E50),
                            ),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Practice',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3E50),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3E50),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 200, // height of the screen minus the height of the AppBar
                child: SingleChildScrollView(
                  child: Wrap( // replaces Row so that the children wrap to the next line if they don't fit
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: 10,
                    children: _imageButtons.map((imageButton) {
                      return LearnCard(imageButton: imageButton);
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}