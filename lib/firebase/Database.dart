import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:restaurant_app/funcs.dart';

class Database {
  Future<String> sendOrder(context, Map order) async {
    try {
      DatabaseReference databaseReference = FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .push();
      order['databaseReference'] = databaseReference.key;
      await databaseReference.set(order);
      return databaseReference.key;
    } on FirebaseException catch(e){
      print(e);
      Funcs().showSnackBar(context, "Error! TRY AGAIN");
      return "";
    } catch (e) {
      print(e);
      Funcs().showSnackBar(context, "Error! TRY AGAIN");
      return "";
    }
  }

  Future<bool> deleteOrder(context, String databaseReference) async {
    try {
      await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(databaseReference)
          .remove();
      Funcs().showSnackBar(context, "Deleted!");
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    }
  }

  Future<bool> updateOrder(context, String databaseReference, String id) async {
    try {
      await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(databaseReference)
          .update({'id': id.trim(), 'idSearch': id.trim().replaceAll(" ", "")});
      Funcs().showSnackBar(context, "Updated!");
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    }
  }
}
