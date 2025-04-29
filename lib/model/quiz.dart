import 'package:hive/hive.dart';

part 'quiz.g.dart';//name of file that will be generated


@HiveType(typeId: 4)
class QuizQuestion extends HiveObject{
  @HiveField(0)
  final String questionText;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String audioPath;

  @HiveField(3)
  final List<QuizAnswer> answers;

  QuizQuestion({
    required this.questionText,
    required this.imagePath,
    required this.audioPath,
    required this.answers,
  });
}

@HiveType(typeId: 5)
class QuizAnswer extends HiveObject{
  @HiveField(0)
  String answerText;

  @HiveField(1)
  bool isCorrect;

  @HiveField(2)
  final String audioPath;

  QuizAnswer({
    required this.answerText,
    required this.isCorrect,
    required this.audioPath,
  });
}