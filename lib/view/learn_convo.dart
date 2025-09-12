import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mozambique_app/model/question.dart';
import 'package:mozambique_app/view/learn_convo_card.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view/navbar.dart';

class LearnConvo extends StatefulWidget {
  final String title; // The title of the page
  final String tag; // The tag used to fetch the questions from the database

  const LearnConvo({
    super.key, 
    required this.title,
    required this.tag
  });

  @override
  State<LearnConvo> createState() => _LearnConvoState();
}

class _LearnConvoState extends State<LearnConvo> {
  late List<Question> _questionList = []; // List to hold all questions
  late List<Question> _filteredQuestions = []; // List to hold filtered questions (CAN CHANGE IF SEARCH WILL NOT BE USED)
  late Future<void> _loadingFuture; // Future to handle loading of data

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    // This fetches from the local Hive database
    try {
      _questionList = await fetchQuestionResponse(widget.tag);
      _filteredQuestions = _questionList;
    } catch (error) {
      log("Error loading data from Hive: $error");
    }
  }

  // TO ADD LATER: SEARCH FUNCTIONALITY
  // void _onSearchChanged(String searchText) {
  //   setState(() {
  //     if (searchText.isEmpty) {
  //       _filteredQuestions = _questionList; // Reset to all words if search is empty
  //     } else {
  //       _filteredQuestions = _questionList.where((question) {
  //         return question.questionText.toLowerCase().contains(searchText.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot){
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Navbar(isPractice: false, onSearchChanged: (test){}),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Enables vertical scrolling
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                        child: Column(
                          children: [
                            // Page Title
                            Container(
                                  margin: EdgeInsets.symmetric(vertical: 0),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontSize: 100,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3E50),
                                      ),
                                    ),
                                ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image(
                                          image: AssetImage('assets/images/bigSmile.png'),
                                          width: 150,
                                          height: 150,
                                        ),
                                      ]
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Image(
                                              image: AssetImage('assets/images/NavyPerson.png'),
                                              width: 100,
                                              height: 100,
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width /4 + 40),
                                            Image(
                                              image: AssetImage('assets/images/GrayPerson.png'),
                                              width: 100,
                                              height: 100,
                                            ),
                                          ],
                                        ),
                                      ]
                                    ),
                                  ]
                                ),
                                SizedBox(width: 40),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image(
                                          image: AssetImage('assets/images/smile.png'),
                                          width: 150,
                                          height: 150,
                                        ),
                                      ]
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Image(
                                              image: AssetImage('assets/images/NavyPerson.png'),
                                              width: 100,
                                              height: 100,
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width/4+40),
                                            Image(
                                              image: AssetImage('assets/images/GrayPerson.png'),
                                              width: 100,
                                              height: 100,
                                            ),
                                          ],
                                        ),
                                      ]
                                    ),
                                  ]
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// First Column (List of Messages)
                          Expanded(
                            child: Column(
                              spacing: 15,
                              children: _filteredQuestions.map((question){
                                return LearnConvoCard(
                                  greeting: question.questionText, 
                                  response: question.responses[1].responseText,
                                  raudio: question.responses[1].audioBytes,
                                  qaudio: question.audioBytes
                                );
                              }).toList(),
                            ),
                          ),
                          /// Second Column (List of Messages)
                          Expanded(
                            child: Column(
                              spacing: 15,
                              children: _filteredQuestions.map((question){
                                return LearnConvoCard(
                                  greeting: question.questionText, 
                                  response: question.responses[0].responseText,
                                  raudio: question.responses[0].audioBytes,
                                  qaudio: question.audioBytes
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      )
    );
  }
}