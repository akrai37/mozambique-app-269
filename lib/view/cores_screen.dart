import 'package:flutter/material.dart';
import 'package:mozambique_app/view/home_card.dart';

class CoresScreen extends StatefulWidget {
  const CoresScreen({super.key});

  @override
  State<CoresScreen> createState() => _CoresScreenState();
}

class _CoresScreenState extends State<CoresScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                const Text(
                  'DIFF EDUCATION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE84C3D),
                  ),
                ),
                Expanded( // ensures the TextField takes up the remaining space
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF95A5A5),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF95A5A5),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(
                          color: Color(0xFF2D3E50),
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Practice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3E50),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
              children: [
                const Text(
                  'Cores',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200, // height of the screen minus the height of the AppBar
            child: SingleChildScrollView(
              child: Wrap( // replaces Row so that the children wrap to the next line if they don't fit
                direction: Axis.horizontal,
                spacing: 10,
                runSpacing: 10,
                children: [
                  HomeCard(img_src: 'assets/images/colors/Red.png', title: 'Vermelho'),
                  HomeCard(img_src: 'assets/images/colors/Orange.png', title: 'Laranja'),
                  HomeCard(img_src: 'assets/images/colors/Yellow.png', title: 'Amarelo'),
                  HomeCard(img_src: 'assets/images/colors/Green.png', title: 'Verde'),
                  HomeCard(img_src: 'assets/images/colors/Blue.png', title: 'Azul'),
                  HomeCard(img_src: 'assets/images/colors/Purple.png', title: 'Roxo'),
                  HomeCard(img_src: 'assets/images/colors/Pink.png', title: 'Rosa'),
                  HomeCard(img_src: 'assets/images/colors/Black.png', title: 'Preto'),
                  HomeCard(img_src: 'assets/images/colors/White.png', title: 'Branco'),
                  HomeCard(img_src: 'assets/images/colors/Gray.png', title: 'Cinza'),
                  HomeCard(img_src: 'assets/images/colors/Brown.png', title: 'Castanho'),
                  HomeCard(img_src: 'assets/images/colors/Gold.png', title: 'Dourado'),
                  HomeCard(img_src: 'assets/images/colors/Silver.png', title: 'Prateado'),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}