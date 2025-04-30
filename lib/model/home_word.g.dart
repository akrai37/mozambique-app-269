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
      imageBytes: fields[3] as Uint8List,
      imagePath: fields[4] as String,
      type: fields[5] as String,
      hasPractice: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HomeWord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.portuguese)
      ..writeByte(2)
      ..write(obj.categoryName)
      ..writeByte(3)
      ..write(obj.imageBytes)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.hasPractice);
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
