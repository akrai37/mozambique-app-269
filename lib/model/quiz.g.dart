// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizQuestionAdapter extends TypeAdapter<QuizQuestion> {
  @override
  final int typeId = 4;

  @override
  QuizQuestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestion(
      questionText: fields[0] as String,
      imageBytes: fields[1] as Uint8List,
      audioBytes: fields[2] as Uint8List,
      imagePath: fields[3] as String,
      audioPath: fields[4] as String,
      answers: (fields[5] as List).cast<QuizAnswer>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestion obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.questionText)
      ..writeByte(1)
      ..write(obj.imageBytes)
      ..writeByte(2)
      ..write(obj.audioBytes)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.audioPath)
      ..writeByte(5)
      ..write(obj.answers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizAnswerAdapter extends TypeAdapter<QuizAnswer> {
  @override
  final int typeId = 5;

  @override
  QuizAnswer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizAnswer(
      answerText: fields[0] as String,
      isCorrect: fields[1] as bool,
      audioPath: fields[2] as String,
      audioBytes: fields[3] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, QuizAnswer obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.answerText)
      ..writeByte(1)
      ..write(obj.isCorrect)
      ..writeByte(2)
      ..write(obj.audioPath)
      ..writeByte(3)
      ..write(obj.audioBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAnswerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
