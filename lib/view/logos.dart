import 'package:flutter/material.dart';

class Logos extends StatelessWidget {
  const Logos({super.key});

  @override
  Widget build(BuildContext context) {// Fills the top space
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Image(
            image: AssetImage('assets/images/logos/scu.png'),
            width: 80,
            height: 80,
          ),
          Image(
            image: AssetImage('assets/images/logos/diffeducation.png'),
            width: 80,
            height: 80,
          ),
          Image(
            image: AssetImage('assets/images/logos/fih.png'),
            width: 80,
            height: 80,
          ),
        ],
      ),
    );
  }
}
