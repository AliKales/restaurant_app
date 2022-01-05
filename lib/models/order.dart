import 'package:hive/hive.dart';

import 'order_status.dart';

part 'order.g.dart';

@HiveType(typeId: 4)
class Order {
  Order({
    required this.orderBy,
    required this.date,
    required this.id,
    required this.foods,
    this.price=0,
    required this.databaseReference,
    required this.idSearch,
    this.note="",
    required this.status,
  });

  @HiveField(0)
  final String? orderBy;
  @HiveField(1)
  final String? date;
  @HiveField(2)
  String? id;
  @HiveField(3)
  List foods;
  @HiveField(4)
  double price;
  @HiveField(5)
  String? databaseReference;
  @HiveField(6)
  String idSearch;
  @HiveField(7)
  String note;
  @HiveField(8)
  OrderStatus status;

  Map<String, dynamic> toMap() {
    return {
      'orderBy': orderBy,
      'date': date,
      'id': id,
      'foods': foods,
      'price': price,
      'databaseReference': databaseReference,
      'idSearch': idSearch,
      'note': note,
      'status': enumToString(status)
    };
  }

  Order.fromJson(Map json)
      : this(
            orderBy: json['orderBy'],
            date: json['date'],
            id: json['id'],
            foods: json['foods'],
            price: json['price'].toDouble(),
            databaseReference: json['databaseReference'],
            idSearch: json['idSearch'],
            note: json['note'] ?? "",
            status: stringToEnum(json['status']));

  static OrderStatus stringToEnum(String value) {
    switch (value) {
      case "cooking":
        return OrderStatus.cooking;
      case "ready":
        return OrderStatus.ready;
      case "waiting":
        return OrderStatus.waiting;
      default:
        return OrderStatus.waiting;
    }
  }

  static String enumToString(OrderStatus value) {
    switch (value) {
      case OrderStatus.cooking:
        return "cooking";
      case OrderStatus.ready:
        return "ready";
      case OrderStatus.waiting:
        return "waiting";
      default:
        return "waiting";
    }
  }
}
