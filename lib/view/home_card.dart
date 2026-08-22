import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/category_badge_mark.dart';
import 'package:mozambique_app/view/learn_convo.dart';
import 'package:mozambique_app/view/learn_screens.dart';
import 'package:mozambique_app/view/practice_convo.dart';
import 'package:mozambique_app/view/quiz_screen.dart';

/// Opens the right screen for a category.
///
/// Shared by the home cards and the navigation panel so there is one definition
/// of "what does tapping this category do", rather than the same branching
/// copied into two places that can drift apart.
void openCategory(
  BuildContext context,
  HomeWord homeWord,
  String type, {
  /// True when moving sideways between categories, so the back stack does not
  /// grow one entry per category the group happened to look at.
  bool replace = false,
}) {
  Widget destination;

  if (type == 'learn') {
    destination = homeWord.type == 'conversation'
        ? LearnConvo(title: homeWord.portuguese, tag: homeWord.categoryName)
        : LearnScreens(title: homeWord.portuguese, tag: homeWord.categoryName);
  } else {
    destination = homeWord.type == 'conversation'
        ? PracticeConvo(title: homeWord.portuguese, tag: homeWord.categoryName)
        : QuizScreen(title: homeWord.portuguese, tag: homeWord.categoryName);
  }

  final MaterialPageRoute route =
      MaterialPageRoute(builder: (_) => destination);

  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}

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
          onTap: () => openCategory(context, homeWord, type),
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