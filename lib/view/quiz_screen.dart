//MAIN DART PAGE THAT CALLS ALL OTHER WIDGETS AND PUTS IT TOGETHER ON THE PAGE
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/view/navbar.dart';
import 'package:mozambique_app/view/quiz_options.dart';
import 'package:mozambique_app/view/quiz_question_widget.dart';
import 'package:mozambique_app/view/quiz_score.dart';
import 'package:mozambique_app/view/reflection_card.dart';
import 'package:mozambique_app/services/progress_service.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';
import 'package:mozambique_app/view_model/quiz_feedback.dart';

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

  // Question index -> whether the learner's first answer was correct.
  // Sparse: a question only appears once it has been answered.
  final Map<int, bool> _answers = {};

  final ProgressService _progress = ProgressService();

  bool get _isComplete =>
      _quizQuestions.isNotEmpty && _answers.length == _quizQuestions.length;

  // Bumped by "try again". Feeding it into each QuizOptions key forces Flutter
  // to build fresh state for them, which clears their selections — simpler and
  // less error-prone than reaching into children to reset them individually.
  int _attempt = 0;

  /// Clears the current answers so the quiz can be taken again.
  ///
  /// Repetition is how the vocabulary sticks, and one tablet passes between
  /// groups, so the next group should not start on the last group's answers.
  /// The saved record is untouched: recordQuizResult keeps the better score, so
  /// retrying can only ever improve it.
  void _tryAgain() {
    setState(() {
      _answers.clear();
      _attempt++;
    });
  }

  void _recordAnswer(int questionIndex, bool wasCorrect) {
    setState(() => _answers[questionIndex] = wasCorrect);

    // Save only once the whole quiz is answered, so a partial run never
    // overwrites a better completed score.
    if (_answers.length != _quizQuestions.length || _quizQuestions.isEmpty) {
      return;
    }

    final int score = _answers.values.where((correct) => correct).length;

    // Read the old best before saving — recordQuizResult is about to replace
    // it, and "better than before" needs to know what before was.
    final CategoryProgress before = _progress.forCategory(widget.tag);
    final int? previousBest = before.completed ? before.quizScore : null;

    _progress.recordQuizResult(
      widget.tag,
      score: score,
      total: _quizQuestions.length,
    );

    _showFeedback(feedbackFor(
      category: widget.tag,
      score: score,
      total: _quizQuestions.length,
      allProgress: _progress.all(),
      previousBest: previousBest,
    ));
  }

  /// Brief summary for the moderator when a quiz finishes.
  ///
  /// Aimed at the moderator, not the learners — it is text, and they cannot
  /// read. The learners get the stars and the face on the reflection card. This
  /// is the line that tells whoever is running the session what to do next.
  void _showFeedback(QuizFeedback feedback) {
    if (!mounted) return;

    final String suggestion = feedback.suggestedCategory == null
        ? ''
        : '  Praticar a seguir: ${feedback.suggestedCategory}.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${feedback.message}$suggestion',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: switch (feedback.tone) {
          FeedbackTone.excellent => const Color(0xFF1E8449),
          FeedbackTone.good => const Color(0xFF2D3E50),
          FeedbackTone.keepPractising => const Color(0xFFB9770E),
        },
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // Drop unanswerable questions here rather than in build(), so that the
      // isFirst/isLast rounded-corner logic still compares against the list
      // that is actually rendered.
      _quizQuestions = (await fetchQuizQuestions(widget.tag))
          .where((question) => question.answers.isNotEmpty)
          .toList();

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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical, // Enables vertical scrolling
                      child: Column(
                        children: [
                          //SECTION TITLE
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 100,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //MIDDLE SCROLL SECTION THAT CALLS ON ALL WIDGETS
                          //QUESTION TEXT AND IMAGE
                          //3 OPTIONS AND THE CORRECT OPTION #
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: _quizQuestions.asMap().entries.map((entry) {
                                final int index = entry.key;
                                final QuizQuestion question = entry.value;

                                return Column(
                                  children: [
                                    QuizQuestionWidget(
                                      question: question,
                                      isFirst: index == 0,
                                    ),
                                    QuizOptions(
                                      key: ValueKey('$index-$_attempt'),
                                      options: question.answers,
                                      isLast: index == _quizQuestions.length - 1,
                                      onFirstAnswer: (correct) =>
                                          _recordAnswer(index, correct),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),

                          // Running score, below the questions.
                          QuizScore(
                            answers: _answers,
                            total: _quizQuestions.length,
                            onTryAgain: _tryAgain,
                          ),

                          // Only once every question is answered, so it reads
                          // as a summary of a finished quiz rather than
                          // feedback on the last tap.
                          if (_isComplete)
                            ReflectionCard(
                              score: _answers.values
                                  .where((correct) => correct)
                                  .length,
                              total: _quizQuestions.length,
                            ),
                        ],
                      ),
                    ),
                  ), 
                  SizedBox(height: 50),
              ],         
            ),
          );
        }
      ),
    );
  }
}