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

  static Future<String> updateOrder({
    required context,
    required String databaseReference,
    required Map<String, dynamic> update,
    bool isID = false,
    bool showMessage = true,
  }) async {
    try {
      DataSnapshot dataSnapshot = await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .child(databaseReference)
          .once();

      if (!dataSnapshot.exists) {
        Funcs().showSnackBar(context,
            "ERROR! This update has no match! This data might be deleted!");
        return "admin-code-52";
      }
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
      if (showMessage) Funcs().showSnackBar(context, "Updated!");
      return "true";
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return "";
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return "";
    }
  }

  static Future<Order?> getOrder({
    required final context,
    required final String databaseReference,
  }) async {
    try {
      DataSnapshot dataSnapshot = await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .child(databaseReference)
          .get();
      if (!dataSnapshot.exists) {
        Funcs().showSnackBar(context, "This order doesn't exist!");
        return null;
      }
      return Order.fromJson(dataSnapshot.value);
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
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
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }

  static Future<List<Order>?> getAllOrders({
    required final context,
  }) async {
    List<Order> listToReturn = [];
    try {
      DataSnapshot dataSnapshot = await FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .get();
      if (!dataSnapshot.exists) {
        Funcs().showSnackBar(context, "There's not any order!");
        return null;
      }

      var a = HashMap.from(dataSnapshot.value);
      a.forEach((key, value) { 
        listToReturn.add(Order.fromJson(value));
      });

      if (listToReturn.isEmpty) {
        Funcs().showSnackBar(context, "There's not any order!");
        return null;
      }
      Funcs().showSnackBar(context, "Done!");
      return listToReturn;
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }
}
