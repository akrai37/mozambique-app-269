import 'package:hive/hive.dart';

part 'quiz.g.dart';//name of file that will be generated


@HiveType(typeId: 4)
class QuizQuestion extends HiveObject{
  @HiveField(0)
  int id;

  @HiveField(2)
  String questionText;

  @HiveField(3)
  String? audioPath;

  QuizQuestion({required this.id, required this.questionText, required this.audioPath});
}

@HiveType(typeId: 5)
class QuizAnswer extends HiveObject{
  @HiveField(0)
  int quizQuestionId;  // Foreign key reference to QuizQuestion

  @HiveField(1)
  String answerText;

  @HiveField(2)
  bool isCorrect;

  QuizAnswer({required this.quizQuestionId, required this.answerText, required this.isCorrect} );
}