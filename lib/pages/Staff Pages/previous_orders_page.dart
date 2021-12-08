import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/order_ticket.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';

import '../../UIs/simple_uis.dart';

class PreviousOrdersPage extends StatefulWidget {
  const PreviousOrdersPage({Key? key, required this.orders}) : super(key: key);
  final List orders;

  @override
  _PreviousOrdersPageState createState() => _PreviousOrdersPageState();
}

class _PreviousOrdersPageState extends State<PreviousOrdersPage> {
  TextEditingController tECID = TextEditingController();

  List<Order> orders = [];
  List<List> foods = [];

  int selectedOrder = 0;
  bool progress1 = false;

  var box = Hive.box('database');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => gel());
  }

  gel() {
    SimpleUIs().showProgressIndicator(context);
    for (var item in widget.orders) {
      orders.add(item);
    }
    Navigator.pop(context);
    setState(() {});
  }

  quit() {
    if (progress1) {
      setState(() {
        progress1 = false;
      });
    } else {
      Navigator.pop(context, orders);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => quit(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppbarForPersons(
          functionForLeadingIcon: () => quit(),
          isPushed: true,
          text: "Previous Oders",
          actions: [],
        ),
        body: Stack(
          children: [
            body(),
            progress1
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ChildOrderTicket(
                        tECID: tECID,
                        price: orders[selectedOrder].price!,
                        foods: List<Food>.generate(
                            orders[selectedOrder].foods!.length,
                            (index) => Food.fromJson(
                                orders[selectedOrder].foods![index])),
                        inkWellOnTap: (i) {},
                        buttonText: "UPDATE",
                        add: () async {
                          if (orders[selectedOrder].id != tECID.text) {
                            SimpleUIs().showProgressIndicator(context);
                            bool boolen1 = await Firestore.updateOrder(
                                context: context,
                                databaseReference:
                                    orders[selectedOrder].databaseReference!,
                                id: tECID.text);
                            bool boolen2 = await Database().updateOrder(
                                context,
                                orders[selectedOrder].databaseReference!,
                                tECID.text);
                            if (boolen1 && boolen2) {
                              setState(() {
                                orders[selectedOrder].id = tECID.text.trim();
                                orders[selectedOrder].id =
                                    tECID.text.trim().replaceAll(" ", "");
                              });
                            }
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  body() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: orders.length,
        itemBuilder: (_, index) {
          return InkWell(
            onLongPress: () {
              setState(() {
                selectedOrder = index;
                progress1 = true;
                tECID.text = orders[selectedOrder].id!;
              });
            },
            child: Slidable(
              key: const ValueKey(1),
              // The start action pane is the one at the left or the top side.
              startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const ScrollMotion(),
                children: [
                  // A SlidableAction can have an icon and/or a label.
                  SlidableAction(
                    onPressed: (contextt) {
                      SimpleUIs.showCustomDialog(
                        context: context,
                        title: "Delete",
                        content: Text(
                          "Are you sure to delete?",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: color4),
                        ),
                        actions: [
                          CustomGradientButton(
                            context: context,
                            color: color1,
                            isOutlined: true,
                            text: "Cancel",
                            func: () {
                              Navigator.pop(context);
                            },
                          ),
                          CustomGradientButton(
                            context: context,
                            text: "Delete",
                            func: () {
                              Navigator.pop(context);
                              deleteOrder(index);
                            },
                          ),
                        ],
                      );
                    },
                    backgroundColor: Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: double.maxFinite,
                decoration: const BoxDecoration(
                    color: color4,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orders[index].id!,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(Funcs().formatMoney(orders[index].price),
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future countChanger(int index) async {
    List listForDialog = [];
    for (var i = 0; i < 51; i++) {
      listForDialog.add(i);
    }
  }

  //FUNCTİONs-----------------------------

  Future deleteOrder(int index) async {
    SimpleUIs().showProgressIndicator(context);
    bool boolen =
        await Database().deleteOrder(context, orders[index].databaseReference!);
    bool boolen2 = await Firestore.deleteOrder(context: context, databaseReference:  orders[index].databaseReference!);
    Navigator.pop(context);
    if (boolen&&boolen2) {
      orders.removeAt(index);
      print(orders);
      box.put("orders", orders);
      setState(() {});
    }
  }
}
