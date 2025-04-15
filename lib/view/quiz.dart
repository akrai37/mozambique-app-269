import 'package:flutter/material.dart';

//may need to change depending on how routing works
class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(53, 64, 79, 255),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromRGBO(53, 64, 79, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  //DIFF EDUCATION LOGO
                  const Text(
                    'DIFF EDUCATION',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE84C3D),
                    ),
                  ),
                  Expanded( // ensures the TextField takes up the remaining space
                    //SEARCH BAR
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
                    //PRACTICE BUTTON
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
          ],

          
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}