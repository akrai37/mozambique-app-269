//DART FILE THAT FORMATS ALL THE QUESTIONS
import 'package:flutter/material.dart';

class QuizQuestion extends StatelessWidget {
  //DICTATES WHAT THE WIDGET TAKES OR WHAT IS REQUIRED TO MAKE THE QUIZ QUESTION
  final String quizQ;
  final String promptImage;
  const QuizQuestion({required this.quizQ, required this.promptImage, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: MediaQuery.of(context).size.width / 1.1 - 15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
        ),
        child: Column(
          //FORMAT OF OVERALL QUESTION
          children: [
            SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width / 1.25 - 15,
              height: 75,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 170, 170, 175),
                border: Border.all(
                  color: const Color.fromARGB(255, 170, 170, 175),
                  width: 2,
                ),
                //ROUNDS THE TOP PART OF THE QUESTION ONLY
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //QUESTION PROMPT
                  Text(
                    quizQ, //CHANGE QUESTION TEXT HERE
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3E50),
                    ),
                  ),
                  SizedBox(width: 10), //SPACING BETWEEN QUESTION PROMPT AND SOUND ICON
                  //SOUND ICON
                  Container(
                    padding: EdgeInsets.all(5), // Space around the icon
                    decoration: BoxDecoration(
                      color: Colors.white, // White circular background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Color(0xFF2D3E50),
                      size: 24,
                    ),
                  ),
                ]
              ),
            ),

            //IMAGE PROMPT FOR THE QUESTION
            Container(
              width: MediaQuery.of(context).size.width / 1.25 - 15,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 135, 135, 140),
                border: Border.all(
                  color: const Color.fromARGB(255, 135, 135, 140),
                  width: 2,
                ),
                //ROUNDS THE BOTTOM PART OF THE QUESTION ONLY
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child:Image(
                image: AssetImage(promptImage), //CHANGE IMAGE HERE
                width: 275,
                height: 275,
              ),
            ),
          ],
        ),
      ),
    );
  }
}