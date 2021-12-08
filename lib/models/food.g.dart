// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 3;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      name: fields[0] as String,
      info: fields[1] as String?,
      price: fields[2] as String,
      count: fields[3] as int,
      category: fields[4] as String,
      id: fields[5] as int,
      searchName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.info)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.searchName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
