import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/category_badge_mark.dart';
import 'package:mozambique_app/view/learn_convo.dart';
import 'package:mozambique_app/view/learn_screens.dart';
import 'package:mozambique_app/view/practice_convo.dart';
import 'package:mozambique_app/view/quiz_screen.dart';

class HomeCard extends StatelessWidget {
  final HomeWord homeWord;
  final String type;

  const HomeCard({
    super.key,
    required this.homeWord, 
    required this.type,
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
            if (type == 'learn') { // If the type is "learn", navigate to LearnScreens
              if (homeWord.type == 'cards') { // If the type is "cards", navigate to LearnScreens
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearnScreens(
                      title: homeWord.portuguese, 
                      tag: homeWord.categoryName,
                    ),
                  ),
                );
              } else if (homeWord.type == 'conversation') { // If the type is "conversation", navigate to LearnConvo
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
            } else if (type == 'practice') { // If the type is "practice", navigate to PracticeConvo
              if (homeWord.type == 'conversation') { // If the type is "conversation", navigate to PracticeConvo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticeConvo(
                      title: homeWord.portuguese,
                      tag: homeWord.categoryName,
                    ),
                  ),
                );
              } else { // If the type is not "conversation", navigate to LearnScreens
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      title: homeWord.portuguese, 
                      tag: homeWord.categoryName,
                    ),
                  ),
                );
              }
            }
          },
          child: Stack(
            children: [
              Column(
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
                      color: const Color(0xFF2D3E50),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Progress marker, top-right. Overlaid rather than taking a row
              // of its own so cards keep a uniform height whether or not a
              // category has been touched.
              Positioned(
                top: 8,
                right: 8,
                child: CategoryBadgeMark(categoryName: homeWord.categoryName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}