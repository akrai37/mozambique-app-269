import 'package:flutter/material.dart';

import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view/home_card.dart';
import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/navbar.dart';
import 'package:mozambique_app/model/vocab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late List<HomeWord> _homeWords = [];
  late Future<void> _loadingFuture;
  Map<String, List<VocabWord>> _allVocabWords = {};
  Map<String, List<VocabWord>> _filteredVocabWords = {};

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadContent();
    // _loadAllVocabWords();
  }

  Future<void> _loadContent() async {
    // Load home words from Hive
    _homeWords = await fetchHomeCards();

    if (_homeWords.isNotEmpty) {
      for (HomeWord homeWord in _homeWords) {
        await precacheImage(AssetImage(homeWord.imagePath), context);
      }
    }

    // Load all vocab words from Hive
    // await _loadAllVocabWords();
  }

  Future<void> _loadAllVocabWords() async {
    await _databaseService.initializeDatabase(); // Ensure the database is initialized
    Map<String, List<VocabWord>> vocabWordsMap = _databaseService.getAllVocabWords(); // Fetch all vocab words from Hive

    if (vocabWordsMap.isNotEmpty) {
      setState(() {
        _allVocabWords = vocabWordsMap;
        _filteredVocabWords = vocabWordsMap; // Initialize filtered words with all words
      });
    }
  }

  void _onSearchChanged(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _filteredVocabWords = _allVocabWords; // Reset to all vocab words if search is empty
      });
    } else {
      Map<String, List<VocabWord>> filteredWords = {};

      _allVocabWords.forEach((category, words) {
        List<VocabWord> filteredList = words.where((word) => word.portuguese.toLowerCase().contains(searchText.toLowerCase())).toList();
        if (filteredList.isNotEmpty) {
          filteredWords[category] = filteredList;
        }
      });

      setState(() {
        _filteredVocabWords = filteredWords; // Update the filtered words
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
            return Center(child: Text('Error:${snapshot.error}'));
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
                    children: _homeWords.map((homeWord) {
                      return HomeCard(homeWord: homeWord);
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