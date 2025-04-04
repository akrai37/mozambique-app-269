// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_word.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeWordAdapter extends TypeAdapter<HomeWord> {
  @override
  final int typeId = 7;

  @override
  HomeWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeWord(
      word: fields[0] as String,
      portuguese: fields[1] as String,
      categoryName: fields[2] as String,
      imagePath: fields[3] as String,
      type: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HomeWord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.portuguese)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
