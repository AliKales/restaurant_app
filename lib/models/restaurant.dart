import 'package:hive/hive.dart';

part 'restaurant.g.dart';

@HiveType(typeId: 1)
class Restaurant {
  Restaurant(
      {required this.username,
      required this.password,
      required this.restaurantName,
      required this.createdDate,
      required this.email,
      required this.paymentDate});

  @HiveField(0)
  String username;
  @HiveField(1)
  String password;
  @HiveField(2)
  String restaurantName;
  @HiveField(3)
  String createdDate;
  @HiveField(4)
  String email;
  @HiveField(5)
  String paymentDate;

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'restaurantName': restaurantName,
      'createdDate': createdDate,
      'email': email,
      'paymentDate':paymentDate
    };
  }

  Restaurant.fromJson(Map json)
      : this(
          username: json['username'],
          password: json['password'],
          restaurantName: json['restaurantName'],
          createdDate: json['createdDate'],
          email: json['email'],
          paymentDate: json['paymentDate'],
        );
}
