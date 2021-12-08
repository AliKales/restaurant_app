// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personnel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonnelAdapter extends TypeAdapter<Personnel> {
  @override
  final int typeId = 2;

  @override
  Personnel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Personnel(
      name: fields[0] as String,
      lastName: fields[1] as String,
      username: fields[2] as String,
      phone: fields[3] as String,
      photoURL: fields[4] as String,
      createdDate: fields[5] as String,
      role: fields[6] as String,
      password: fields[7] as String,
      id: fields[8] as String,
      restaurantName: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Personnel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.photoURL)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.password)
      ..writeByte(8)
      ..write(obj.id)
      ..writeByte(9)
      ..write(obj.restaurantName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
