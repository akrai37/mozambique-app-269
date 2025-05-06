import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view/learn_card.dart';
import 'package:mozambique_app/view/navbar.dart';
import 'package:mozambique_app/model/vocab.dart';

class LearnScreens extends StatefulWidget {
  final String title;
  final String tag;

  const LearnScreens({
    super.key,
    required this.title,
    required this.tag,
  });

  @override
  State<LearnScreens> createState() => _LearnScreensState();
}

class _LearnScreensState extends State<LearnScreens> {
  late List<VocabWord> _imageButtons = [];
  late List<VocabWord> _filteredImageButtons = [];
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    // This fetches from the local Hive database
    try {
      _imageButtons = await fetchVocabCards(widget.tag);

      _filteredImageButtons = _imageButtons; // Initialize filtered words with all words

      // Preload images
      for (VocabWord imageButton in _imageButtons) {
        await precacheImage(MemoryImage(imageButton.imageBytes), context);
      }
    } catch (error) {
      log("Error loading data from Hive: $error");
    }
  }

  void _onSearchChanged(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredImageButtons = _imageButtons; // Reset to all words if search is empty
      } else {
        _filteredImageButtons = _imageButtons.where((imageButton) {
          return imageButton.portuguese.toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              Navbar(isPractice: false, onSearchChanged: _onSearchChanged),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3E50),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Enables vertical scrolling
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap( // replaces Row so that the children wrap to the next line if they don't fit
                      direction: Axis.horizontal,
                      spacing: 10,
                      runSpacing: 10,
                      children: _filteredImageButtons.map((imageButton) {
                        return LearnCard(
                            key: ValueKey(imageButton.portuguese), // Use a unique key for each card
                            imageButton: imageButton,
                          );
                      }).toList(),
                    ),
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