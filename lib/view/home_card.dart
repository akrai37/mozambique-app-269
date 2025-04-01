import 'package:flutter/material.dart';

import 'package:mozambique_app/view/learn_screens.dart';

class HomeCard extends StatelessWidget {
  final String img;
  final String title;
  final String tag;

  const HomeCard({
    super.key,
    required this.img,
    required this.title,
    required this.tag,
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
              builder: (context) => LearnScreens(title: title, tag: tag),
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
                  image: AssetImage(img.isNotEmpty ? img: 'assets/images/learn/Numbers.png'),
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
                title,
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