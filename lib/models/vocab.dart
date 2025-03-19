import 'package:hive/hive.dart';

part 'vocab.g.dart'; //name of file that will be generated

@HiveType(typeId: 1)
class VocabWord extends HiveObject{
  @HiveField(0)
  int categoryId;  // Foreign key reference

  @HiveField(1)
  String word;

  @HiveField(2)
  String portuguese;

  @HiveField(3)
  String imagePath;

  @HiveField(4)
  String audioPath;

  VocabWord( this.categoryId, this.word, this.portuguese, this.imagePath, this.audioPath);
}