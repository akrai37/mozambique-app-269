import 'package:flutter/material.dart';

import 'package:mozambique_app/view/cores_screen.dart';

class HomeCard extends StatelessWidget {
  final String img_src;
  final String title;

  const HomeCard({
    super.key,
    required this.img_src,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: InkWell(
        onTap: () {
          if (title == 'Cores') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CoresScreen(),
              ),
            );
          } else {
            // Handle other cases or do nothing
          }
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
                  image: AssetImage(img_src.isNotEmpty ? img_src: 'assets/images/learn/Numbers.png'),
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