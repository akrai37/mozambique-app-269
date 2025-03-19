import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 2)
class Question {

  @HiveField(0)
  String questionText;

  @HiveField(1)
  int categoryId;

  @HiveField(2)
  String? audioPath;

  Question( this.questionText, this.categoryId, this.audioPath);
}

@HiveType(typeId: 3)
class Response {
  @HiveField(0)
  int id;

  @HiveField(1)
  String responseText;

  @HiveField(2)
  int categoryId;

  @HiveField(3)
  String? audioPath;

  @HiveField(4)
  String emotion;

  Response(this.id, this.responseText, this.categoryId, this.audioPath, this.emotion);
}