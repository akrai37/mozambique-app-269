//MAIN DART PAGE THAT CALLS ALL OTHER WIDGETS AND PUTS IT TOGETHER ON THE PAGE
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/view/navbar.dart';
import 'package:mozambique_app/view/quiz_options.dart';
import 'package:mozambique_app/view/quiz_question_widget.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final String tag;

  const QuizScreen({
    super.key,
    required this.title,
    required this.tag,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _quizQuestions = [];
  late Future<void> _loadingFuture;

  @override initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      _quizQuestions = await fetchQuizQuestions(widget.tag);

      // Preload images
      for (QuizQuestion question in _quizQuestions) {
        await precacheImage(MemoryImage(question.imageBytes), context);
      }
    } catch (error) {
      log("Error loading data from Hive: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(53, 64, 79, 255),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            // Show a loading indicator while waiting for images to load
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Color.fromRGBO(53, 64, 79, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Navbar(
                  onSearchChanged: (test) {}, 
                  isPractice: true,
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
                                  child: Text(
                                    widget.title,
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
                                      children: _quizQuestions.map((question) {
                                        return Column(
                                          children: [
                                            QuizQuestionWidget(
                                              question: question,
                                              isFirst: question == _quizQuestions.first,
                                            ),
                                            QuizOptions(
                                              option1: question.answers[0],
                                              option2: question.answers[1],
                                              option3: question.answers[2],
                                              isLast: question == _quizQuestions.last,
                                            ),
                                          ],
                                        );
                                      }).toList(),
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
          );
        }
      ),
    );
  }
}