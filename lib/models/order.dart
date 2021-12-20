
import 'package:hive/hive.dart';

part 'order.g.dart';

@HiveType(typeId: 4)
class Order {
  Order(
      {required this.orderBy,
      required this.date,
      required this.id,
      required this.foods,
      required this.price,
      required this.databaseReference,
      required this.idSearch,
      this.note});

  @HiveField(0)
  final String? orderBy;
  @HiveField(1)
  final String? date;
  @HiveField(2)
  String? id;
  @HiveField(3)
  final List? foods;
  @HiveField(4)
  final double? price;
  @HiveField(5)
  String? databaseReference;
  @HiveField(6)
  String idSearch;
  @HiveField(7)
  String? note;

  Map<String, dynamic> toMap() {
    return {
      'orderBy': orderBy,
      'date': date,
      'id': id,
      'foods': foods,
      'price':price,
      'databaseReference':databaseReference,
      'idSearch':idSearch,
      'note':note
    };
  }

  Order.fromJson(Map json)
      : this(
          orderBy: json['orderBy'],
          date: json['date'],
          id: json['id'],
          foods: json['foods'],
          price: json['price'].toDouble(),
          databaseReference:json['databaseReference'],
          idSearch:json['idSearch'],
          note:json['note']??""
        );
}
