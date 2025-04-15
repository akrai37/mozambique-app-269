import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LearnScreens(
                title: homeWord.portuguese, 
                tag: homeWord.categoryName,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xFFECF0F1),
          ),
          child: Column(
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
              // Text(
              //   icon,
              //   style: TextStyle(
              //     fontSize: 150,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
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