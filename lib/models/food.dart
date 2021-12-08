import 'package:hive/hive.dart';

part 'food.g.dart';

@HiveType(typeId: 3)
class Food {

  Food({
    required this.name,
    this.info = "",
    required this.price,
    required this.count,
    required this.category,
    required this.id,
    required this.searchName,
  });

  @HiveField(0)
  String name;
  @HiveField(1)
  String? info;
  @HiveField(2)
  String price;
  @HiveField(3)
  int count;
  @HiveField(4)
  String category;
  @HiveField(5)
  final int id;
  @HiveField(6)
  String searchName;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'info': info,
      'price': price,
      'count': count,
      'category': category,
      'id': id,
      'searchName': searchName
    };
  }

  Food.fromJson(Map json)
      : this(
            name: json['name'],
            info: json['info'],
            price: json['price'],
            count: json['count'],
            category: json['category'],
            id: json['id'],
            searchName: json['searchName']);
}
