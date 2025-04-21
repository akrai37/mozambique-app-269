import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'home_word.g.dart'; //name of file that will be generated

@HiveType(typeId: 7)
class HomeWord extends HiveObject {
  @HiveField(0)
  final String word;

  @HiveField(1)
  final String portuguese;

  @HiveField(2)
  final String categoryName;

  @HiveField(3)
  Uint8List imageBytes;

  @HiveField(4)
  final String imagePath;

  @HiveField(5)
  final String type;

  HomeWord({
    required this.word,
    required this.portuguese,
    required this.categoryName,
    required this.imageBytes,
    required this.imagePath,
    required this.type,
  });

  // Method to create HomeWord from JSON
  factory HomeWord.fromJson(Map<String, dynamic> json) {
    return HomeWord(
      word: json['word'] as String,
      portuguese: json['portuguese'] as String,
      categoryName: json['categoryName'] as String,
      imageBytes: json['imageBytes'] as Uint8List,
      imagePath: json['imagePath'] as String,
      type: json['type'] as String,
    );
  }

  // Method to convert HomeWord to JSON
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'portuguese': portuguese,
      'categoryName': categoryName,
      'imageBytes': imageBytes,
      'imagePath': imagePath,
      'type': type,
    };
  }
}