import 'package:flutter/material.dart';

import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/view/practice/practice_screens.dart';

class PHomeCard extends StatelessWidget {
  final HomeWord homeWord;

  const PHomeCard({
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
              builder: (context) => PracticeScreens(
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
                child: Image(
                  image: AssetImage(homeWord.imagePath),
                  width: 200,
                  height: 200,
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