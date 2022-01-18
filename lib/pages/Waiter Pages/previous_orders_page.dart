import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/order_ticket.dart';
import 'package:restaurant_app/UIs/widget_order_ticket.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/order_status.dart';
import 'package:restaurant_app/size.dart';

import '../../UIs/simple_uis.dart';
import 'add_food_page.dart';

class PreviousOrdersPage extends StatefulWidget {
  const PreviousOrdersPage({Key? key, required this.orders}) : super(key: key);
  final List orders;

  @override
  _PreviousOrdersPageState createState() => _PreviousOrdersPageState();
}

class _PreviousOrdersPageState extends State<PreviousOrdersPage> {
  TextEditingController tECID = TextEditingController();
  TextEditingController tECSearchID = TextEditingController();

  List<Order> orders = [];
  List<List> foods = [];
  List<Order> ordersBySearch = [];
  List<Order>? ordersToUpdateID;

  Order? selectedOrder;
  Order? databaseOrder;

  bool progress1 = false;

  ///* [isUpdating] active the changing
  bool isUpdating = false;

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
          actions: [
            (selectedOrder != null && ordersToUpdateID != null)
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      tECSearchID.clear();
                      if (ordersBySearch.isNotEmpty) {
                        setState(() {
                          ordersBySearch = [];
                        });
                        return;
                      }
                      SimpleUIs.showCustomDialog(
                          context: context,
                          activeCancelButton: true,
                          title: "SEARCH ID",
                          content: CustomTextField(
                            textEditingController: tECSearchID,
                          ),
                          actions: [
                            CustomGradientButton(
                              context: context,
                              text: "SEARCH",
                              func: () {
                                Navigator.pop(context);
                                searchById(tECSearchID.text);
                              },
                            ),
                          ]);
                    },
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: Icon(
                      ordersBySearch.isNotEmpty
                          ? Icons.cancel_outlined
                          : Icons.search,
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
        body: Stack(
          children: [
            body(),
            selectedOrder != null
                ? Container(
                    color: color1,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomTextField(
                                  textEditingController: tECID,
                                  isFilled: true,
                                  filledColor: Colors.grey[350],
                                  text: "Id or Name:",
                                  colorHint: Colors.black,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(color: Colors.black),
                                ),
                              ),
                            ),
                            CustomGradientButton(
                              context: context,
                              text: "Update",
                              func: () {
                                updateID(
                                    true, selectedOrder!.databaseReference!);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig().setHight(2),
                        ),
                        CustomGradientButton(
                          context: context,
                          text: isUpdating ? "Stop Update" : "Start Update",
                          func: () {
                            if (isUpdating) {
                              stopUpdateFun();
                            } else {
                              updateFun();
                            }
                          },
                        ),
                        OrderTicket(
                          tECID: tECID,
                          isTextFieldActive: false,
                          isNoSlide: true,
                          absoring: !isUpdating,
                          price: selectedOrder?.price ?? 0,
                          foods: getList(),
                          funcNote: (value){
                            selectedOrder!.note=value;
                          },
                          inkWellOnTap: (value) {
                            countChanger(value);
                          },
                          add: () {
                            FocusScope.of(context).unfocus();
                            addFood();
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            (ordersToUpdateID != null && ordersToUpdateID!.length > 1)
                ? Container(
                    color: color1,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  ordersToUpdateID = null;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: color4,
                              ),
                            ),
                          ),
                          CustomGradientButton(
                            context: context,
                            text: "Update All",
                            func: () {
                              updateAll();
                            },
                          ),
                          Text(
                            "to ${tECID.text}",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: color4, fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            itemCount: ordersToUpdateID!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  WidgetOrderTicket(
                                    order: ordersToUpdateID![index],
                                    isChef: false,
                                  ),
                                  ordersToUpdateID![index].id ==
                                          tECID.text.trim()
                                      ? const SizedBox.shrink()
                                      : const Icon(
                                          Icons.arrow_upward,
                                          color: color4,
                                        ),
                                  ordersToUpdateID![index].id ==
                                          tECID.text.trim()
                                      ? const SizedBox.shrink()
                                      : CustomGradientButton(
                                          context: context,
                                          text: "Update",
                                          isOutlined: true,
                                          color: color1,
                                          func: () {
                                            updateOneFromMultiple(index);
                                          },
                                        )
                                ],
                              );
                            },
                          )
                        ],
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
      child: ordersBySearch.isNotEmpty
          ? widgetListViewForOrders(ordersBySearch)
          : widgetListViewForOrders(orders),
    );
  }

  ListView widgetListViewForOrders(list) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (_, index) {
        return InkWell(
          onLongPress: () async {
            if (ordersBySearch.isNotEmpty) {
              setState(() {
                selectedOrder = list[index];
                tECID.text = selectedOrder!.id!;
              });
            } else {
              SimpleUIs().showProgressIndicator(context);
              Order? order = await Database.getOrder(
                  context: context,
                  databaseReference: list[index].databaseReference);
              if (order != null) {
                setState(() {
                  selectedOrder = order;
                  tECID.text = order.id!;
                });
                orders[orders.indexWhere((element) =>
                        element.databaseReference == order.databaseReference)] =
                    order;
                box.put("orders", orders);
              }
              Navigator.pop(context);
            }
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
                            //deleteOrder(index);
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: double.maxFinite,
              decoration: const BoxDecoration(
                  color: color4,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    list[index].id!,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(Funcs().formatMoney(list[index].price),
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //FUNCTİONs-----------------------------
  Future countChanger(int index) async {
    List<Food> tempOutput = getList();
    List listForDialog = [];
    for (var i = 0; i < 100; i++) {
      listForDialog.add(i);
    }
    var value = await SimpleUIs()
        .showGeneralDialogFunc(context, listForDialog, tempOutput.length);
    if (value == 0) {
      tempOutput[index].count = 1;
      setState(() {
        tempOutput.removeWhere((element) => element == tempOutput[index]);
      });
    } else {
      setState(() {
        tempOutput[index].count = value;
      });
    }

    selectedOrder!.foods = List.generate(tempOutput.length, (index) => tempOutput[index].toMap());
    double amount = 0;
    for (var food in getList()) {
      amount += double.parse(food.price) * food.count;
    }
    selectedOrder!.price = amount;
    setState(() {});
  }

  Future stopUpdateFun() async {
    SimpleUIs().showProgressIndicator(context);
    selectedOrder!.status = OrderStatus.waiting;
    for (var i = 0; i < selectedOrder!.foods.length; i++) {
      if (selectedOrder!.foods[i].runtimeType == Food) {
        selectedOrder!.foods[i] = selectedOrder!.foods[i].toMap();
      }
    }
    String response = await Database.updateOrder(
        context: context,
        databaseReference: selectedOrder!.databaseReference!,
        update: selectedOrder!.toMap());
    Navigator.pop(context);
    if (response == "true") {
      setState(() {
        isUpdating = false;
      });
    }
  }

  Future updateFun() async {
    SimpleUIs().showProgressIndicator(context);
    try {
      FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .child(selectedOrder!.databaseReference!)
          .runTransaction((mutableData) {
        if (mutableData.value == null) {
          Navigator.pop(context);
          Funcs().showSnackBar(context, "ERROR! PLEASE TRY AGAIN");
          return mutableData;
        }
        SimpleUIs().showProgressIndicator(context);
        if (Order.fromJson(mutableData.value).status == OrderStatus.cooking) {
          Funcs()
              .showSnackBar(context, "This order is already getting ready!!!");
          Database.updateOrder(
                  context: context,
                  databaseReference: selectedOrder!.databaseReference!,
                  update: {"status": Order.enumToString(OrderStatus.cooking)})
              .then((value) {
            setState(() {
              isUpdating = false;
            });
            Navigator.pop(context);
          });
        } else if (Order.fromJson(mutableData.value).status !=
            OrderStatus.ready) {
          Database.updateOrder(
                  context: context,
                  databaseReference: selectedOrder!.databaseReference!,
                  update: {"status": Order.enumToString(OrderStatus.updating)})
              .then((value) {
            if (value == "true") {
              setState(() {
                isUpdating = true;
              });
            }
            Navigator.pop(context);
          });
        } else {
          Navigator.pop(context);
        }

        return mutableData;
      });
    } on FirebaseException {
      Navigator.pop(context);
      Funcs().showSnackBar(context, "ERROR!");
    } catch (e) {
      Navigator.pop(context);
      Funcs().showSnackBar(context, "ERROR!");
    }
  }

  List<Food> getList() {
    return List<Food>.generate(
      selectedOrder!.foods.length,
      (index) => selectedOrder!.foods[index].runtimeType == Food
          ? selectedOrder!.foods[index]
          : Food.fromJson(
              selectedOrder!.foods[index],
            ),
    );
  }

  Future addFood() async {
    List<dynamic>? value = await Funcs().navigatorPush(
      context,
      AddFoodPage(pickedFoods: getList()),
    );

    if (value != null) {
      selectedOrder!.foods += value;
      double amount = 0;
      for (var food in getList()) {
        amount += double.parse(food.price) * food.count;
      }
      selectedOrder!.price = amount;
      setState(() {});
    }

    // if (value != null) {
    //   for (var i = 0; i < value.length; i++) {
    //     value[i]=value[i].toMap();
    //   }
    //   print(value);
    //   if (ordersBySearch.isNotEmpty) {
    //     ordersBySearch[selectedOrder].foods += value;
    //   } else {
    //     orders[selectedOrder].foods += value;
    //   }
    //   setState(() {});
    // }
  }

  void updateOneFromMultiple(int index) {
    updateID2(ordersToUpdateID![index], false, false);
  }

  Future updateAll() async {
    for (var item in ordersToUpdateID!) {
      await updateID2(item, false, false);
    }
  }

  Future updateID(bool isID, String databaseReference) async {
    if (selectedOrder!.idSearch == tECID.text.trim().replaceAll(" ", "")) {
      Funcs().showSnackBar(context, "Id has not been changed!");
      return;
    }
    SimpleUIs().showProgressIndicator(context);
    ordersToUpdateID = await Database.getOrders(
        context: context, idSearch: selectedOrder!.idSearch);

    Navigator.pop(context);
    setState(() {
      if (ordersToUpdateID == []) {
        ordersToUpdateID = null;
      }
    });
    if (ordersToUpdateID?.length == 1) {
      updateID2(ordersToUpdateID![0], isID, true);
    }
  }

  Future updateID2(Order valueOrder, bool isID, bool isSingle) async {
    SimpleUIs().showProgressIndicator(context);
    String response = await Database.updateOrder(
        context: context,
        databaseReference: valueOrder.databaseReference!,
        isID: isID,
        update: {
          'id': tECID.text.trim(),
          'idSearch': tECID.text.trim().replaceAll(" ", "")
        });
    if (response == "admin-code-31") {
      Navigator.pop(context);
      SimpleUIs.showCustomDialog(
          context: context,
          title: "ID ALREADY EXISTS",
          content: const Text(
            "This ID already exists but if this is another ORDER for this ID, please PRESS LONG on 'YES'",
            style: TextStyle(color: color4),
          ),
          actions: [
            CustomGradientButton(
              context: context,
              color: color1,
              isOutlined: true,
              text: "CANCEL",
              func: () {
                Navigator.pop(context);
              },
            ),
            CustomGradientButton(
              context: context,
              text: "YES",
              func: () {
                Funcs().showSnackBar(context, "LONG PRESS!!!!");
              },
              longPress: () {
                Navigator.pop(context);
                if (selectedOrder!.id != tECID.text) {
                  updateID(false, selectedOrder!.databaseReference!);
                }
              },
            )
          ]);
      return;
    } else if (response != "") {
      if (isSingle) {
        selectedOrder!.id = tECID.text.trim();
        selectedOrder!.idSearch = tECID.text.trim().replaceAll(" ", "");
      } else {
        if (selectedOrder!.databaseReference == valueOrder.databaseReference) {
          selectedOrder!.id = tECID.text.trim();
          selectedOrder!.idSearch = tECID.text.trim().replaceAll(" ", "");
        }
        ordersToUpdateID!
            .firstWhere((element) =>
                element.databaseReference == valueOrder.databaseReference)
            .id = tECID.text.trim();
        ordersToUpdateID!
            .firstWhere((element) =>
                element.databaseReference == valueOrder.databaseReference)
            .idSearch = tECID.text.trim().replaceAll(" ", "");
      }

      box.put("orders", orders);
      // if (ordersBySearch.isNotEmpty) {
      //   ordersBySearch[selectedOrder].id = tECID.text.trim();
      //   ordersBySearch[selectedOrder].id =
      //       tECID.text.trim().replaceAll(" ", "");
      // } else {
      //   orders[selectedOrder].id = tECID.text.trim();
      //   orders[selectedOrder].id = tECID.text.trim().replaceAll(" ", "");
      // }

    }
    setState(() {});
    Navigator.pop(context);
  }

  Future searchById(String id) async {
    SimpleUIs().showProgressIndicator(context);
    await Database.getOrders(context: context, idSearch: id).then((value) {
      if (value != null) {
        setState(() {
          ordersBySearch = value;
        });
      }
    });

    Navigator.pop(context);
  }

  // Future deleteOrder(int index) async {
  //   SimpleUIs().showProgressIndicator(context);
  //   bool? boolen = await Database.deleteOrder(
  //       context: context, databaseReference: orders[index].databaseReference!);
  //   Navigator.pop(context);
  //   if (boolen == null) {
  //     return;
  //   }
  //   if (boolen) {
  //     orders.removeAt(index);
  //     print(orders);
  //     box.put("orders", orders);
  //     setState(() {});
  //   }
  // }
}
