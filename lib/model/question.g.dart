// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 2;

  @override
  Question read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Question(
      id: fields[0] as String,
      questionText: fields[1] as String,
      categoryName: fields[2] as String,
      audioPath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.questionText)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.audioPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResponseAdapter extends TypeAdapter<Response> {
  @override
  final int typeId = 3;

  @override
  Response read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Response(
      responseText: fields[0] as String,
      questionId: fields[1] as String,
      audioPath: fields[2] as String?,
      emotion: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Response obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.responseText)
      ..writeByte(1)
      ..write(obj.questionId)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.emotion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
