import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/models/restaurant.dart';

class Firestore {
  final box = Hive.box("database");
  final int version = 1;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Restaurant?> getRestaurant(context) async {
    try {
      var value = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .get();
      if (!value.exists) {
        return Restaurant(
            username: "username",
            password: "ozel-admin-code:31",
            restaurantName: "restaurantName",
            createdDate: "createdDate",
            email: "email",
            paymentDate: "paymentDate");
      }
      return Restaurant.fromJson(value.data() as Map);
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }

  Future<Map?> getPolicies(context) async {
    Map? map = box.get("policies");
    try {
      if (map == null) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("policy")
            .doc("policies")
            .get();

        box.put("policies", documentSnapshot.data() as Map);

        return documentSnapshot.data() as Map;
      } else {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("policy")
            .where("update", isNotEqualTo: map['update'])
            .limit(1)
            .get();
        if (querySnapshot.docs.isEmpty) {
          return map;
        }
        box.put("policies", querySnapshot.docs[0].data() as Map);
        return querySnapshot.docs[0].data() as Map;
      }
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      print(e);
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }

  Future<bool?> checkVersion(context) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("update")
          .doc("update")
          .get();
      if (!documentSnapshot.exists) {
        return null;
      }
      Map update = documentSnapshot.data() as Map;
      int versionDB = update['version'];
      if (versionDB > version) {
        return false;
      } else {
        return true;
      }
    } on FirebaseException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Restaurant?> checkAdminPassword(context, email, password) async {
    try {
      var value = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('email', isEqualTo: email)
          .where('password', isNotEqualTo: password)
          .limit(1)
          .get();
      if (value.docs.isEmpty) {
        return Restaurant(
            username: "username",
            password: "ozel-admin-code:31",
            restaurantName: "restaurantName",
            createdDate: "createdDate",
            email: "email",
            paymentDate: "paymentDate");
      }
      return Restaurant.fromJson(value.docs[0].data());
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }

  Future<bool> updateRestaurant(context, updateValue) async {
    try {
      await firestore
          .collection("restaurants")
          .doc(Auth().getEMail())
          .update(updateValue);
      return true;
    } on FirebaseException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future deleteRestaurant(context) async {
    try {
      await firestore.collection("restaurants").doc(Auth().getEMail()).delete();
    } catch (e) {}
  }

  ///* if there's error, it returns null
  Future<dynamic> createARestaurant(Restaurant restaurant) async {
    try {
      await firestore
          .collection("restaurants")
          .doc(Auth().getEMail())
          .set(restaurant.toMap());
      return restaurant;
    } on FirebaseException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  ///* [addPersonnel] this method create a new personnel on database
  ///* first it send onto database and then put into local databse
  ///* if it was successful it return true
  static Future<bool> addPersonnel(
      {required Personnel personnel, required context}) async {
    CollectionReference collectionToPersonnels = FirebaseFirestore.instance
        .collection("restaurants")
        .doc(Auth().getEMail())
        .collection("personnels");
    try {
      var box = Hive.box('database');
      await collectionToPersonnels.doc(personnel.id).set(personnel.toMap());
      List personnels = box.get("personnels") ?? [];
      personnels.insert(0, personnel);
      box.put("personnels", personnels);
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!!!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!!!");
      return false;
    }
  }

  static Future<bool> checkUsername({
    required context,
    required String username,
  }) async {
    CollectionReference collectionToPersonnels = FirebaseFirestore.instance
        .collection("restaurants")
        .doc(Auth().getEMail())
        .collection("personnels");
    try {
      var usernameCheck = await collectionToPersonnels
          .where("username", isEqualTo: username)
          .get();
      if (usernameCheck.docs.isNotEmpty) {
        Funcs().showSnackBar(context, "This 'username' is already taken!!!");
        return false;
      }
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!!!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!!!");
      return false;
    }
  }

  ///* [getPersonnels] returns the list which is goten from local databse but if there's new personnels on databse it gives with new ones
  static Future<List<Personnel>> getPersonnels({
    required final String lastPersonnelId,
    required final context,
    required final List<Personnel> list,
  }) async {
    List<Personnel> listReturn = list;

    CollectionReference collectionToPersonnels = FirebaseFirestore.instance
        .collection("restaurants")
        .doc(Auth().getEMail())
        .collection("personnels");

    if (lastPersonnelId == "") {
      /////
      var get = await collectionToPersonnels.limit(4).get();
      if (get.docs.isEmpty) {
        return listReturn;
      } else {
        for (var item in get.docs) {
          listReturn.add(Personnel.fromJson(item.data() as Map));
        }
        return listReturn;
      }
      /////////
    } else if (lastPersonnelId != "") {
      ///////
      var get2 = await collectionToPersonnels
          .orderBy("id")
          .startAfter([lastPersonnelId])
          .limit(4)
          .get();
      if (get2.docs.isEmpty) {
        return listReturn;
      } else {
        for (var item in get2.docs) {
          listReturn.add(Personnel.fromJson(item.data() as Map));
        }
        return listReturn;
      }
      //////
    } else {
      return listReturn;
    }

    // //if local database has no data it gets directly from database
    // if (personnelsFromLocalDB.isEmpty) {
    //   await collectionToPersonnels.get().then((value) {
    //     if (value.docs.isNotEmpty) {
    //       for (var json in value.docs) {
    //         listReturn.add(Personnel.fromJson(json.data() as Map));
    //       }
    //     }
    //   });
    // } else {
    //   await collectionToPersonnels
    //       .orderBy('id')
    //       .endBefore([personnelsFromLocalDB[0].id])
    //       .get()
    //       .then((value) {
    //         if (value.docs.isNotEmpty) {
    //           for (var json in value.docs.reversed.toList()) {
    //             listReturn.insert(0, Personnel.fromJson(json.data() as Map));
    //           }
    //         }
    //       });
    // }
  }

  static Future<bool> deletePersonnel({
    required final context,
    required final String id,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("personnels")
          .doc(id)
          .delete();
      Funcs().showSnackBar(context, "Personnel has been deleted!");
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    }
  }

  static Future<bool> updatePersonnel(
      {required final context,
      required final Personnel personnel,
      required final String where,
      required final Map<String, Object> mapForUpdate}) async {
    if (where == "username") {
      bool checkUsername = await Firestore.checkUsername(
          context: context, username: mapForUpdate['username'].toString());
      if (!checkUsername) return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("personnels")
          .doc(personnel.id)
          .update(mapForUpdate);
      Funcs().showSnackBar(context, "${where.toUpperCase()}'s been changed");
      return true;
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    }
  }

  static Future<Personnel?> logInStaff(
      {required final context,
      required final String username,
      required final String password,
      required final String role}) async {
    try {
      var staff = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("personnels")
          .limit(1)
          .where('role', isEqualTo: role)
          .where('username', isEqualTo: username.trim())
          .where('password', isEqualTo: password.trim())
          .get();

      if (staff.docs.isEmpty) {
        Funcs().showSnackBar(
            context, "No user found with this username and password!");
        return null;
      } else {
        Funcs().showSnackBar(context, "Logged In!");
        return Personnel.fromJson(staff.docs[0].data());
      }
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }

  static Future<Map?> getFoodMenuOrCategory({
    required final context,
    required final bool isFoodMenu,
  }) async {
    try {
      var staff = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("infos")
          .doc(isFoodMenu ? "foodMenu" : "foodCategory")
          .get();
      if (staff.exists) {
        if (isFoodMenu) {
          List list = [];
          for (var item in staff.data()?['data'] ?? []) {
            list.add(Food.fromJson(item));
          }
          return {
            'data': list,
            'updateDate': staff.data()?['updateDate'] ?? []
          };
        } else {
          return staff.data() as Map;
        }
      } else {
        Funcs().showSnackBar(context,
            isFoodMenu ? "No Food Menu found!" : "No Food Category found!");
        return {};
      }
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return null;
    }
  }

  static Future<bool> setFoodMenuOrCategory({
    required context,
    required final bool isFoodMenu,
    required List list,
  }) async {
    try {
      list.sort((a, b) => a.toString().compareTo(b.toString()));
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("infos")
          .doc(isFoodMenu ? "foodMenu" : "foodCategory")
          .set({'data': list, 'updateDate': DateTime.now().toIso8601String()});

      Funcs().showSnackBar(context, "Uploaded!");
      return true;
    } on FirebaseException {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR!");
      return false;
    }
  }

  static Future<bool> payOrder({
    required context,
    required Order order,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("payments")
          .doc(DateTime.now().year.toString()) //DateTime.now().month.toString()
          .update({
        DateTime.now().month.toString(): FieldValue.arrayUnion([order.toMap()]),
      });
      Funcs().showSnackBar(context, "PAID 2");
      return true;
    } on FirebaseException catch (e) {
      if (e.code == "not-found") {
        bool comeBack = await createPaymentInfo(context: context, order: order);
        return comeBack;
      }
      Funcs().showSnackBar(context, "ERROR! TRY AGAIN");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR! TRY AGAIN");
      return false;
    }
  }

  static Future<bool> createPaymentInfo({
    required context,
    required Order order,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("payments")
          .doc(DateTime.now().year.toString())
          .set({
        DateTime.now().month.toString(): [order.toMap()],
      });
      Funcs().showSnackBar(context, "PAID 2");
      return true;
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR! TRY AGAIN");
      return false;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR! TRY AGAIN");
      return false;
    }
  }

  static Future<List<Map>?> getStatisticks({
    required context,
    required String year,
  }) async {
    List<Map> listReturn = [];
    try {
      var value = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(Auth().getEMail())
          .collection("payments")
          .doc(year)
          .get();
      if (value.exists) {
        Funcs().showSnackBar(context, "Done");
        for (var i = 1; i < 13; i++) {
          listReturn
              .add({'month': i, 'payments': value.data()?[i.toString()] ?? []});
        }
        return listReturn;
      } else {
        Funcs().showSnackBar(context, "No Data!");
        return null;
      }
    } on FirebaseException catch (e) {
      Funcs().showSnackBar(context, "ERROR! TRY AGAIN");
      return null;
    } catch (e) {
      Funcs().showSnackBar(context, "ERROR! TRY AGAIN");
      return null;
    }
  }
}
