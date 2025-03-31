import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert' show json;

import 'package:mozambique_app/model/image_button.dart';
import 'package:mozambique_app/view/learn_card.dart';

class LearnScreens extends StatefulWidget {
  final String title;
  final String tag;
  // final List<ImageButton> imageButtons;

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

  @override
  void initState() {
    super.initState();

    

    // Get the list of image buttons from a .json file

    // // Load the JSON file
    // final String jsonString = await rootBundle.loadString('assets/json/all_cards.json');
    // // Decode the JSON string into a list of dynamic objects
    // final data = json.decode(jsonString);
    // final cards = data[widget.tag.toLowerCase()];
    
    // _imageButtons = List<ImageButton>.from(cards.map((item) => ImageButton.fromJson(item)));

    rootBundle.loadString('assets/json/all_cards.json').then((jsonString) {
      final data = json.decode(jsonString);
      final cards = data[widget.tag.toLowerCase()];
      setState(() {
        _imageButtons = List<ImageButton>.from(cards.map((item) => ImageButton.fromJson(item)));
      });
    }).catchError((error) {
      print("Error loading JSON: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF95A5A5),
                      ),
                      prefixIcon: const Icon(
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
                // children: [
                //   LearnCard(img: 'assets/images/colors/Red.png', title: 'Vermelho'),
                //   LearnCard(img: 'assets/images/colors/Orange.png', title: 'Laranja'),
                //   LearnCard(img: 'assets/images/colors/Yellow.png', title: 'Amarelo'),
                //   LearnCard(img: 'assets/images/colors/Green.png', title: 'Verde'),
                //   LearnCard(img: 'assets/images/colors/Blue.png', title: 'Azul'),
                //   LearnCard(img: 'assets/images/colors/Purple.png', title: 'Roxo'),
                //   LearnCard(img: 'assets/images/colors/Pink.png', title: 'Rosa'),
                //   LearnCard(img: 'assets/images/colors/Black.png', title: 'Preto'),
                //   LearnCard(img: 'assets/images/colors/White.png', title: 'Branco'),
                //   LearnCard(img: 'assets/images/colors/Gray.png', title: 'Cinza'),
                //   LearnCard(img: 'assets/images/colors/Brown.png', title: 'Castanho'),
                //   LearnCard(img: 'assets/images/colors/Gold.png', title: 'Dourado'),
                //   LearnCard(img: 'assets/images/colors/Silver.png', title: 'Prateado'),
                // ],
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}