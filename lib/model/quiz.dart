import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'quiz.g.dart';//name of file that will be generated


@HiveType(typeId: 4)
class QuizQuestion extends HiveObject{
  @HiveField(0)
  final String questionText;

  @HiveField(1)
  final Uint8List imageBytes;

  @HiveField(2)
  final Uint8List audioBytes;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final String audioPath;

  @HiveField(5)
  final List<QuizAnswer> answers;

  QuizQuestion({
    required this.questionText,
    required this.imageBytes,
    required this.audioBytes,
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

  @HiveField(3)
  final Uint8List audioBytes;

  QuizAnswer({
    required this.answerText,
    required this.isCorrect,
    required this.audioPath,
    required this.audioBytes,
  });
}