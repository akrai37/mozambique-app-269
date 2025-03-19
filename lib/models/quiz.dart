import 'package:hive/hive.dart';

part 'quiz.g.dart';//name of file that will be generated

@HiveType(typeId: 4)
class Quiz extends HiveObject{
  @HiveField(0)
  int id;

  @HiveField(1)
  int categoryId;

  @HiveField(2)
  String title;

  Quiz(this.id, this.categoryId, this.title);
}

@HiveType(typeId: 5)
class QuizQuestion extends HiveObject{
  @HiveField(0)
  int id;

  @HiveField(1)
  int quizId;  // Foreign key reference to Quiz

  @HiveField(2)
  String questionText;

  @HiveField(3)
  String? audioPath;

  QuizQuestion(this.id, this.quizId, this.questionText, this.audioPath);
}

@HiveType(typeId: 6)
class QuizAnswer extends HiveObject{
  @HiveField(0)
  int quizQuestionId;  // Foreign key reference to QuizQuestion

  @HiveField(1)
  String answerText;

  @HiveField(2)
  bool isCorrect;

  QuizAnswer(this.quizQuestionId, this.answerText, this.isCorrect);
}