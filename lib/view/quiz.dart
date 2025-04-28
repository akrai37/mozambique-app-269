//MAIN DART PAGE THAT CALLS ALL OTHER WIDGETS AND PUTS IT TOGETHER ON THE PAGE
import 'package:flutter/material.dart';
import 'package:mozambique_app/view/quiz_options.dart';
import 'package:mozambique_app/view/quiz_qs.dart';

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
                            color: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Ensures content is aligned to the left
                  children: [
                    //LEFT SIDE MARGIN
                    SizedBox(width: MediaQuery.of(context).size.width / 15 - 15), // Adds left spacing
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft, // Ensures "Rosto" stays at the top-left
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligns everything to the left
                          children: [
                            //SECTION TITLE
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: const Text(
                                'Rosto',
                                style: TextStyle(
                                  fontSize: 75,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFECF0F1),
                                ),
                              ),
                            ),
                            //MIDDLE SCROLL SECTION THAT CALLS ON ALL WIDGETS
                            //QUESTION TEXT AND IMAGE
                            //3 OPTIONS AND THE CORRECT OPTION #
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical, // Enables vertical scrolling
                                child: Column(
                                  children: [
                                    QuizQuestion(quizQ: "O que é isso?", promptImage: 'assets/images/Prac-Face/Head.png', isFirst: true),
                                    QuizOptions(option1: "Boca", option2: "Cabelo", option3: "Olho", correctOption: 2, isLast: false),
                                    QuizQuestion(quizQ: "O que é isso?", promptImage: 'assets/images/Prac-Face/Nose.png', isFirst: false),
                                    QuizOptions(option1: "Nariz", option2: "Boca", option3: "Cabelo", correctOption: 1, isLast: false),
                                    QuizQuestion(quizQ: "O que é isso?", promptImage: 'assets/images/Prac-Face/Eyes.png', isFirst: false),
                                    QuizOptions(option1: "Cabelo", option2: "Nariz", option3: "Olho", correctOption: 3, isLast: false),
                                    QuizQuestion(quizQ: "O que é isso?", promptImage: 'assets/images/Prac-Face/Mouth.png', isFirst: false),
                                    QuizOptions(option1: "Boca", option2: "Olho", option3: "Nariz", correctOption: 1, isLast: true)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ), 
          ],         
        ),
      ),
    );
  }
}