// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 5;

  @override
  OrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OrderStatus.waiting;
      case 1:
        return OrderStatus.cooking;
      case 2:
        return OrderStatus.ready;
      default:
        return OrderStatus.waiting;
    }
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    switch (obj) {
      case OrderStatus.waiting:
        writer.writeByte(0);
        break;
      case OrderStatus.cooking:
        writer.writeByte(1);
        break;
      case OrderStatus.ready:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
