// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 6;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      categoryName: fields[0] as String,
      conversationText: (fields[1] as List).cast<ConvoLine>(),
      imagePath: fields[2] as String,
      imageBytes: fields[3] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.categoryName)
      ..writeByte(1)
      ..write(obj.conversationText)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.imageBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConvoLineAdapter extends TypeAdapter<ConvoLine> {
  @override
  final int typeId = 8;

  @override
  ConvoLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConvoLine(
      convoText: fields[0] as String,
      audioPath: fields[1] as String?,
      audioBytes: fields[2] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, ConvoLine obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.convoText)
      ..writeByte(1)
      ..write(obj.audioPath)
      ..writeByte(2)
      ..write(obj.audioBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConvoLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
