import 'package:hive/hive.dart';
part 'order_status.g.dart';


@HiveType(typeId: 5)
enum OrderStatus{
  @HiveField(0)
  waiting,
  @HiveField(1)
  cooking,
  @HiveField(2)
  ready
}