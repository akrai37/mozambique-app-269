import 'package:hive/hive.dart';

part 'conversation.g.dart'; //name of file that will be generated


@HiveType(typeId: 7)
class Conversation extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String categoryName;

  @HiveField(2)
  String conversationText;

  Conversation(this.id, this.categoryName, this.conversationText);
}