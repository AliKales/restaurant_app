import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/order_status.dart';

class Database {
  DatabaseReference databaseReference = FirebaseDatabase(
          databaseURL:
              "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
      .reference()
      .child("orders")
      .child(Auth().getUID());

  Future<String> sendOrder(context, Order order, bool sendAnyway) async {
    try {
      if (sendAnyway == false) {
        DataSnapshot dataSnapshot = await databaseReference
            .orderByChild("idSearch")
            .equalTo(order.idSearch)
            .once();

        if (dataSnapshot.exists) {
          Funcs().showSnackBar(context, "This ID already exists!");
          return "admin-code-31";
        }
      }

      await databaseReference
          .child(order.databaseReference!)
          .set(order.toMap());

      Funcs().showSnackBar(context, "Order has been sent");

      return "databaseReference";
    } on FirebaseException catch (e) {
      print(e);
      Funcs().showSnackBar(context, "Error! TRY AGAIN");
      return "";
    } catch (e) {
      print(e);
      Funcs().showSnackBar(context, "Error! TRY AGAIN");
      return "";
    }
  }

  static Future<bool?> deleteOrder(
      {required final context,
      required final String databaseReference,
      bool isPaying = false,
      bool isCheckExist = true}) async {
    try {
      if (isCheckExist) {
        DataSnapshot dataSnapshot;
        DatabaseReference dR = FirebaseDatabase(
                databaseURL:
                    "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
            .reference()
            .child("orders")
            .child(Auth().getUID());

        dataSnapshot = await dR
            .orderByChild("databaseReference")
            .equalTo(databaseReference)
            .once();

        if (!dataSnapshot.exists) {
          Funcs().showSnackBar(context, "There's not any order with this ID!");
          return null;
        }
      }

      await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .child(databaseReference)
          .remove();
      Funcs().showSnackBar(context, isPaying ? "PAID 1" : "Deleted!");
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    }
  }

  static Future<String> updateOrder(
      {required context,
      required String databaseReference,
      required Map<String, dynamic> update,
      bool isID = false}) async {
    try {
      if (isID) {
        DataSnapshot dataSnapshot = await FirebaseDatabase(
                databaseURL:
                    "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
            .reference()
            .child("orders")
            .child(Auth().getUID())
            .orderByChild("idSearch")
            .equalTo(update['id'])
            .once();

        if (dataSnapshot.exists) {
          Funcs().showSnackBar(context, "This ID already exists!");
          return "admin-code-31";
        }
      }

      await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .child(databaseReference)
          .update(update);
      Funcs().showSnackBar(context, "Updated!");
      return "true";
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return "";
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return "";
    }
  }

  static Future<List<Order>?> getOrders({
    required final context,
    required final String idSearch,
    final isPaying = false,
  }) async {
    List<Order> returnlist = [];
    DataSnapshot dataSnapshot;
    DatabaseReference databaseReference = FirebaseDatabase(
            databaseURL:
                "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
        .reference()
        .child("orders")
        .child(Auth().getUID());


    try {
      dataSnapshot = await databaseReference
          .orderByChild("idSearch")
          .equalTo(idSearch.trim().replaceAll(" ", ""))
          .once();

      if (!dataSnapshot.exists) {
        Funcs().showSnackBar(context, "There's not any order with this ID!");
        return null;
      }

      var a = HashMap.from(dataSnapshot.value);
      a.forEach((key, value) {
        if (!isPaying) {
          returnlist.add(Order.fromJson(value));
        } else if (value['status'] == Order.enumToString(OrderStatus.ready)) {
          returnlist.add(Order.fromJson(value));
        }
      });

      if (returnlist.isEmpty) {
        Funcs().showSnackBar(context, "There's not any order with this ID!");
        return null;
      }

      return returnlist;
    } on FirebaseException catch (e) {
      print(e);
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      print(e);
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }
}
