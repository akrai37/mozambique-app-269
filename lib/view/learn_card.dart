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
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage(img.isNotEmpty ? img : 'assets/images/learn/Numbers.png'),
                        width: 200,
                        height: 200,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Speaker Icon
              Positioned(
                bottom: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    print('Speaker icon tapped for $title');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues( alpha: 0.3),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}