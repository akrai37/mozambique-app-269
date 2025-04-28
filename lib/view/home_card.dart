import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/learn_convo.dart';
import 'package:mozambique_app/view/learn_screens.dart';

class HomeCard extends StatelessWidget {
  final HomeWord homeWord;

  const HomeCard({
    super.key,
    required this.homeWord,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Material(
        color: const Color(0xFFECF0F1),
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            if (homeWord.type == "cards") { // If the type is "cards", navigate to LearnScreens
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LearnScreens(
                    title: homeWord.portuguese, 
                    tag: homeWord.categoryName,
                  ),
                ),
              );
            } else { // If the type is not "cards", navigate to LearnConvo
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LearnConvo(
                  title: homeWord.portuguese, 
                  tag: homeWord.categoryName,
                ),
              ),
            );
            }
            
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: homeWord.imageBytes.isNotEmpty
                  ? Image.memory(
                      homeWord.imageBytes,
                      height: 200,
                      width: 200,
                    )
                  : const Icon(
                      Icons.error,
                      size: 200,
                    ),
              ),
              Text(
                homeWord.portuguese,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}