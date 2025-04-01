import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert' show json;

import 'package:mozambique_app/model/image_button.dart';
import 'package:mozambique_app/view/learn_card.dart';

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
  late List<ImageButton> _imageButtons = [];
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load the JSON file
      String jsonString = await rootBundle.loadString('assets/json/all_cards.json');
      final data = json.decode(jsonString);
      final cards = data[widget.tag];

      _imageButtons = List<ImageButton>.from(cards.map((item) => ImageButton.fromJson(item)));

      // Preload images
      for (var imageButton in _imageButtons) {
        await precacheImage(AssetImage(imageButton.img), context);
      }
    } catch (error) {
      print("Error loading JSON data: $error");
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
                      'DIFF EDUCATION',
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
                      return LearnCard(
                        title: imageButton.word,
                        img: imageButton.img,
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