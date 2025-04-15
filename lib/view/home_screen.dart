import 'package:flutter/material.dart';

import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view/home_card.dart';
import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late List<HomeWord> _homeWords = [];
  late Future<void> _loadingFuture;
  List<HomeWord> _filteredHomeWords = [];
  Map<String, List<String>> _vocabWordsMap = {}; // Map to store vocab words by category

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    // Load home words from Hive
    _homeWords = await fetchHomeCards();

    _filteredHomeWords = _homeWords; // Initialize filtered words with all words

    // Preload images
    for (HomeWord homeWord in _homeWords) {
      await precacheImage(MemoryImage(homeWord.imageBytes), context);
    }

    // Load all vocab words from Hive (for search functionality)
    await _loadAllVocabWords();
  }

  Future<void> _loadAllVocabWords() async {
    await _databaseService.initializeDatabase(context); // Ensure the database is initialized
    _vocabWordsMap = _databaseService.getAllPortugueseWords(); // Fetch all Portuguese vocab words
  }

  void _onSearchChanged(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _filteredHomeWords = _homeWords; // Reset to all words if search is empty
      });
    } else {
      setState(() {
        _filteredHomeWords = _homeWords.where((homeWord) {
          return homeWord.portuguese.toLowerCase().contains(searchText.trim().toLowerCase()) ||
                 _vocabWordsMap[homeWord.categoryName]?.any((portuguese) => portuguese.toLowerCase().contains(searchText.trim().toLowerCase())) == true;
        }).toList();
      });
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
              Navbar(onSearchChanged: _onSearchChanged),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                  children: [
                    const Text(
                      'Olá!',
                      style: TextStyle(
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
                    children: _filteredHomeWords.map((homeWord) {
                        return HomeCard(
                          key: ValueKey(homeWord.portuguese), // Use a unique key for each card
                          homeWord: homeWord,
                        );
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