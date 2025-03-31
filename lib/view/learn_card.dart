import 'package:flutter/material.dart';

class LearnCard extends StatelessWidget {
  final String img;
  final String title;

  const LearnCard({
    super.key,
    required this.img,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: InkWell(
        onTap: () {
          print('Tapped on $title');
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