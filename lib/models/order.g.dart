// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderAdapter extends TypeAdapter<Order> {
  @override
  final int typeId = 4;

  @override
  Order read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Order(
      orderBy: fields[0] as String?,
      date: fields[1] as String?,
      id: fields[2] as String?,
      foods: (fields[3] as List).cast<dynamic>(),
      price: fields[4] as double,
      databaseReference: fields[5] as String?,
      idSearch: fields[6] as String,
      note: fields[7] as String,
      status: fields[8] as OrderStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Order obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.orderBy)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.foods)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.databaseReference)
      ..writeByte(6)
      ..write(obj.idSearch)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
