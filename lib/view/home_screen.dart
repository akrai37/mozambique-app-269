import 'package:flutter/material.dart';

import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view_model/home_search.dart';
import 'package:mozambique_app/view/home_card.dart';
import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/navbar.dart';

class HomeScreen extends StatefulWidget {
  final String type;

  const HomeScreen({
    super.key,
    this.type = 'learn', // Default type is 'learn'
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _type;
  final DatabaseService _databaseService = DatabaseService();
  late List<HomeWord> _homeWords = []; // List to hold all Learn words
  late Future<void> _loadingFuture; // Future to load content
  late List<HomeWord> _filteredHomeWords = []; // List to hold filtered Home words based on search
  final List<HomeWord> _practiceCategories = []; // List to hold Practice categories
  final List<HomeWord> _toRemove = []; // List to remove categories from Learn home page
  Map<String, List<String>> _vocabWordsMap = {}; // Map to store vocab words by category

  @override
  void initState() {
    super.initState();

    _type = widget.type;
    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    // Load home words from Hive
    _homeWords = await fetchHomeCards();

    // Preload images
    for (HomeWord homeWord in _homeWords) {
      await precacheImage(MemoryImage(homeWord.imageBytes), context);
    }

    await _checkPractice();

    // Load all vocab words from Hive (for search functionality)
    await _loadAllVocabWords();
    
    _filteredHomeWords = _type == 'learn' 
      ? _homeWords.where((homeWord) => _toRemove.every((practiceCat) => practiceCat.categoryName != homeWord.categoryName)).toList() // Check if the category is not in _toRemove
      : _practiceCategories; // Initialize filtered words with all words
  }

  Future<void> _loadAllVocabWords() async {
    await _databaseService.initializeDatabase(context); // Ensure the database is initialized
    _vocabWordsMap = _databaseService.getAllPortugueseWords(); // Fetch all Portuguese vocab words
  }

  // Handles search text changes.
  //
  // The filtering itself lives in view_model/home_search.dart as a pure
  // function so it can be unit tested; see test/home_search_test.dart.
  void _onSearchChanged(String searchText) {
    setState(() {
      _filteredHomeWords = filterHomeWords(
        allWords: _type == 'learn' ? _homeWords : _practiceCategories,
        hiddenCategories: _toRemove,
        vocabByCategory: _vocabWordsMap,
        searchText: searchText,
        isLearnScreen: _type == 'learn',
      );
    });
  }

  // Fills _practiceCategories and _toRemove lists based on the categories in _homeWords
  Future<void> _checkPractice() async {
    // Reset first: _loadContent() runs again after every sync, and without this
    // both lists keep growing, which duplicates every card on the home grid.
    _practiceCategories.clear();
    _toRemove.clear();

    for (HomeWord homeWord in _homeWords) {
      // Check if the category has practice words and add to _practiceCategories
      if (_databaseService.hasCategoryPractice(homeWord.categoryName)) {
        _practiceCategories.add(homeWord);
      }

      // Check if the category does not have a Learn screen and add to _toRemove
      if (!(_databaseService.hasCategoryLearn(homeWord.categoryName))) {
        _toRemove.add(homeWord);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _type == 'learn' ? Colors.white : Color.fromRGBO(53, 64, 79, 1),
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
              Navbar(
                onSearchChanged: _onSearchChanged,
                isHomeScreen: true, // Pass the isHomeScreen flag to Navbar
                isLearnScreen: _type == 'learn',
                isPractice: _type != 'learn',
                onSync: () async {
                  await _loadContent();
        
                  setState(() {}); // Force a rebuild
                }
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Enables vertical scrolling
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                          children: [
                            Text(
                              _type == 'learn' ? 'Aprender' : 'Prática',
                              style: TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                                color: _type == 'learn' ? Color(0xFF2D3E50) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Wrap( // replaces Row so that the children wrap to the next line if they don't fit
                          direction: Axis.horizontal,
                          spacing: 10,
                          runSpacing: 10,
                          children: _filteredHomeWords.map((homeWord) {
                              return HomeCard(
                                key: ValueKey(homeWord.portuguese), // Use a unique key for each card
                                homeWord: homeWord,
                                type: _type
                              );
                          }).toList(),
                        ),
                      ),
                    ],
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