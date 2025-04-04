// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabWordAdapter extends TypeAdapter<VocabWord> {
  @override
  final int typeId = 1;

  @override
  VocabWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabWord(
      categoryName: fields[0] as String,
      word: fields[1] as String,
      portuguese: fields[2] as String,
      imagePath: fields[3] as String,
      audioPath: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VocabWord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.categoryName)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.portuguese)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.audioPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
