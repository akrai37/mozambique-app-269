import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 2)
class Question {
  @HiveField(0)
  String id;

  @HiveField(1)
  String questionText;

  @HiveField(2)
  String categoryName;

  @HiveField(3)
  String? audioPath;

  Question( {required this.id, required this.questionText, required this.categoryName, required this.audioPath});
}

@HiveType(typeId: 3)
class Response {
  @HiveField(0)
  String responseText;

  @HiveField(1)
  String questionId; //foreign key

  @HiveField(2)
  String? audioPath;

  @HiveField(3)
  String emotion;

  Response( {required this.responseText, required this.questionId, required this.audioPath, required this.emotion});
}