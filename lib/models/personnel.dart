import 'package:hive/hive.dart';

part 'personnel.g.dart';

@HiveType(typeId: 2)
class Personnel {
  Personnel(
      {required this.name,
      required this.lastName,
      required this.username,
      required this.phone,
      required this.photoURL,
      required this.createdDate,
      required this.role,
      required this.password,
      required this.id,
      required this.restaurantName});

  @HiveField(0)
  String name;
  @HiveField(1)
  String lastName;
  @HiveField(2)
  String username;
  @HiveField(3)
  String phone;
  @HiveField(4)
  final String photoURL;
  @HiveField(5)
  final String createdDate;
  @HiveField(6)
  final String role;
  @HiveField(7)
  String password;
  @HiveField(8)
  final String id;
  @HiveField(9)
  final String restaurantName;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'username': username,
      'phone': phone,
      'photoURL': photoURL,
      'createdDate': createdDate,
      'role': role,
      'password': password,
      'id': id,
      'restaurantName':restaurantName
    };
  }

  Personnel.fromJson(Map json)
      : this(
            name: json['name'],
            lastName: json['lastName'],
            username: json['username'],
            phone: json['phone'],
            photoURL: json['photoURL'],
            createdDate: json['createdDate'],
            role: json['role'],
            password: json['password'],
            id: json['id'],
            restaurantName:json['restaurantName']);
}
