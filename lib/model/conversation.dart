import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'conversation.g.dart'; //name of file that will be generated


@HiveType(typeId: 6)
class Conversation extends HiveObject {

  @HiveField(0)
  String categoryName;

  @HiveField(1)
  List<ConvoLine> conversationText;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  Uint8List imageBytes;

  Conversation({ required this.categoryName, required this.conversationText, required this.imagePath, required this.imageBytes});
}

@HiveType(typeId: 8)
class ConvoLine extends HiveObject {
   @HiveField(0)
  String convoText;

  @HiveField(1)
  String? audioPath;

  @HiveField(2)
  Uint8List audioBytes;

  ConvoLine({required this.convoText, required this.audioPath, required this.audioBytes});
}