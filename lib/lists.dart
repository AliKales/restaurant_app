import 'package:hive/hive.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';


class Lists {
  static Map? foods;
  static Map? categories;

  var box = Hive.box('database');

  List roles = ["Select a role", "Waiter", "Chef", "Cashier"];

  Future<bool> getFoodsAndCategories(context) async {
    foods = box.get("foods") ??
        await Firestore.getFoodMenuOrCategory(
            isFoodMenu: true, context: context);
    categories = box.get("categories") ??
        await Firestore.getFoodMenuOrCategory(
            isFoodMenu: false, context: context);
    if (foods == null || categories == null) {
      return false;
    } else {
      Funcs().showSnackBar(context, "Updated");
      return true;
    }
  }

  Future<bool> getUpdatedFoodsAndCategories(context) async {
    foods = await Firestore.getFoodMenuOrCategory(
        isFoodMenu: true, context: context);
    categories = await Firestore.getFoodMenuOrCategory(
        isFoodMenu: false, context: context);

    box.put("foods", foods);
    box.put("categories", categories);
    
    if (foods == null || categories == null) {
      return false;
    } else {
      return true;
    }
  }
}
