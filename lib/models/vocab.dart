import 'package:hive/hive.dart';

part 'vocab.g.dart'; //name of file that will be generated

@HiveType(typeId: 1)
class VocabWord extends HiveObject{
  @HiveField(0)
  int id;

  @HiveField(1)
  String word;

  @HiveField(2)
  int categoryId;  // Foreign key reference

  @HiveField(3)
  String imagePath;

  @HiveField(4)
  String audioPath;

  VocabWord(this.id, this.word, this.categoryId, this.imagePath, this.audioPath);
}