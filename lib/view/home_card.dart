import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String icon;
  final String title;

  const HomeCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xFFECF0F1),
        ),
        child: Column(
          children: [
            // Image(
            //   image: AssetImage('assets/images/temp.png'),
            //   width: 100,
            //   height: 100,
            // ),
            Text(
              icon,
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}