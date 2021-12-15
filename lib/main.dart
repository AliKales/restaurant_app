import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/pages/select_restaurant_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(RestaurantAdapter());
  Hive.registerAdapter(PersonnelAdapter());
  Hive.registerAdapter(FoodAdapter());
  Hive.registerAdapter(OrderAdapter());
  await Hive.openBox('database');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior:kIsWeb? MyScrollBehavior():null,
        title: 'Flutter Demo',
        theme: ThemeData(scaffoldBackgroundColor: color1),
        home: const SelectRestaurantPage());
  }
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => { 
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
