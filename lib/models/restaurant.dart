import 'package:hive/hive.dart';

part 'restaurant.g.dart';

@HiveType(typeId: 1)
class Restaurant {
  Restaurant(
      {required this.username,
      required this.password,
      required this.restaurantName,
      required this.createdTime,
      required this.email});

  @HiveField(0)
  String username;
  @HiveField(1)
  String password;
  @HiveField(2)
  String restaurantName;
  @HiveField(3)
  String createdTime;
  @HiveField(4)
  String email;

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'restaurantName': restaurantName,
      'createdTime': createdTime,
      'email':email
    };
  }

  Restaurant.fromJson(Map json)
      : this(
            username: json['username'],
            password: json['password'],
            restaurantName: json['restaurantName'],
            createdTime: json['createdTime'],
            email: json['email'],);
}
