import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'vocab.g.dart'; //name of file that will be generated

@HiveType(typeId: 1)
class VocabWord extends HiveObject{
  @HiveField(0)
  final String categoryName;  // Foreign key reference

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String portuguese;

  @HiveField(3)
  Uint8List imageBytes;

  @HiveField(4)
  Uint8List audioBytes;

  @HiveField(5)
  final String imagePath;

  @HiveField(6)
  final String audioPath;

  VocabWord({
    required this.categoryName,
    required this.word, 
    required this.portuguese, 
    required this.imageBytes,
    required this.audioBytes,
    required this.imagePath, 
    required this.audioPath,
  });

  // Method to create VocabWord from JSON
  factory VocabWord.fromJson(Map<String, dynamic> json) {
    return VocabWord(
      categoryName: json['categoryName'] as String,
      word: json['word'] as String,
      portuguese: json['portuguese'] as String,
      imageBytes: json['imageBytes'] as Uint8List,
      audioBytes: json['audioBytes'] as Uint8List,
      imagePath: json['imagePath'] as String,
      audioPath: json['audioPath'] as String,
    );
  }

  // Method to convert VocabWord to JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'word': word,
      'portuguese': portuguese,
      'imageBytes': imageBytes,
      'audioBytes': audioBytes,
      'imagePath': imagePath,
      'audioPath': audioPath,
    };
  }
}