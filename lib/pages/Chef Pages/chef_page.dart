import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/UIs/widget_order_ticket.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/models/food.dart';

import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/order_status.dart';

import '../../UIs/custom_gradient_button.dart';
import '../../UIs/custom_textfield.dart';
import '../../UIs/login_page.dart';
import '../../firebase/Firestore.dart';
import '../../models/personnel.dart';
import '../../size.dart';

class ChefPage extends StatefulWidget {
  const ChefPage({
    Key? key,
  }) : super(key: key);

  @override
  _ChefPageState createState() => _ChefPageState();
}

class _ChefPageState extends State<ChefPage> {
  List<Order> orders = [];
  final _innerList = <WidgetOrderTicket>[];

  Personnel? personnel;

  TextEditingController tECPassword = TextEditingController();
  TextEditingController tECUsername = TextEditingController();

  bool progress1 = false;

  String lastDeleted = "";

  @override
  void initState() {
    super.initState();
  }

  listeners() {
    FirebaseDatabase(
            databaseURL:
                "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
        .reference()
        .child("orders")
        .child(Auth().getUID())
        .onChildRemoved
        .listen((event) {
      int index = orders.indexWhere((element) =>
          element.databaseReference ==
          event.snapshot.value['databaseReference']);
      if (index != -1 &&
          lastDeleted != event.snapshot.value['databaseReference']) {
        orders.removeAt(index);
        _innerList.removeAt(index);
        if (mounted) {
          setState(() {});
        }
      }
    });
    FirebaseDatabase(
            databaseURL:
                "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
        .reference()
        .child("orders")
        .child(Auth().getUID())
        .onChildChanged
        .listen((event) {
      int index = orders.indexWhere((element) =>
          element.databaseReference ==
          event.snapshot.value['databaseReference']);
      if (index != -1) {
        orders.removeAt(index);
        _innerList.removeAt(index);

        if (Order.fromJson(event.snapshot.value).status != OrderStatus.ready) {
          orders.insert(index, Order.fromJson(event.snapshot.value));

          _innerList.insert(
              index,
              WidgetOrderTicket(
                order: Order.fromJson(event.snapshot.value),
                longPress: (note) {
                  SimpleUIs.showCustomDialog(
                      context: context,
                      title: "NOTE:",
                      content: Text(
                        note ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: color4),
                      ));
                },
                funcDone: () async {
                  doneOrder(
                      Order.fromJson(event.snapshot.value).databaseReference);
                },
              ));
        }

        if (mounted) {
          setState(() {});
        }
      }
    });
    FirebaseDatabase(
            databaseURL:
                "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
        .reference()
        .child("orders")
        .child(Auth().getUID())
        .onChildAdded
        .listen((event) {
      final order = Order.fromJson(event.snapshot.value);

      if (Order.fromJson(event.snapshot.value).status != OrderStatus.ready) {
        orders.add(order);

        _innerList.add(WidgetOrderTicket(
          order: order,
          longPress: (note) {
            SimpleUIs.showCustomDialog(
                context: context,
                title: "NOTE:",
                content: Text(
                  note ?? "",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: color4),
                ));
          },
          funcDone: () async {
            doneOrder(order.databaseReference);
          },
        ));
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarForPersons(
        text: "Chef",
      ),
      body: body(),
    );
  }

  body() {
    if (personnel != null) {
      return widgetLoggedIn();
    } else {
      return LoginPage(
        tECUsername: tECUsername,
        tECPassword: tECPassword,
        context: context,
        progress1: progress1,
        function: () async {
          setState(() {
            progress1 = true;
          });
          FocusScope.of(context).unfocus();
          await Firestore.logInStaff(
                  context: context,
                  username: tECUsername.text,
                  password: tECPassword.text,
                  role: "Chef")
              .then((value) {
            if (value != null) {
              personnel = value;
              listeners();
            }
          });
          setState(() {
            progress1 = false;
          });
        },
      );
    }
  }

  CustomScrollView widgetLoggedIn() {
    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => _innerList[index],
          childCount: orders.length,
        ),
      ),
    ]);
  }

  //FUNCTİONS --------------

  Future doneOrder(databaseReference) async {
    lastDeleted = databaseReference;
    await Database.updateOrder(
        context: context,
        databaseReference: databaseReference,
        update: {'status': Order.enumToString(OrderStatus.ready)});
  }
}
