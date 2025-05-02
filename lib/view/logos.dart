import 'package:flutter/material.dart';

class Logos extends StatelessWidget {
  const Logos({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Image(
          image: AssetImage('assets/images/logos/scu.png'),
          width: 200,
          height: 200,
        ),
        Image(
          image: AssetImage('assets/images/logos/diffeducation.png'),
          width: 200,
          height: 200,
        ),
        Image(
          image: AssetImage('assets/images/logos/fih.png'),
          width: 200,
          height: 200,
        ),
      ],
    );
  }
}
