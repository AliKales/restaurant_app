import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/login_page.dart';
import 'package:restaurant_app/UIs/order_ticket.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/UIs/widget_order_ticket.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/pages/Cashier%20Pages/pre_orders_page.dart';
import 'package:restaurant_app/size.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({Key? key}) : super(key: key);

  @override
  _CashierPageState createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  Personnel? personnel;

  TextEditingController tECUsername = TextEditingController();
  TextEditingController tECPassword = TextEditingController();
  TextEditingController tECSearch = TextEditingController();

  bool progress1 = false;
  bool progress2 = false;
  bool progress3 = false;
  bool progress4 = false;
  bool cB1 = false;

  List<Order> orders = [];
  List<Order> selectedOrders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarForPersons(
        text: "Cashier",
      ),
      floatingActionButton: personnel == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Funcs().navigatorPush(context, const PreOrdersPage());
              },
              backgroundColor: color2,
              child: const Icon(
                Icons.history,
                color: color4,
              ),
            ),
      body: body(),
    );
  }

  body() {
    if (personnel != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                textEditingController: tECSearch,
                text: "ID for Search",
              ),
              SizedBox(height: SizeConfig().setHight(3)),
              if (orders.isNotEmpty)
                IconButton(
                  onPressed: () {
                    clear();
                  },
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                )
              else
                CustomGradientButton(
                  context: context,
                  loading: progress2,
                  text: "Search",
                  func: () async {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      progress2 = true;
                      cB1 = false;
                    });
                    if (tECSearch.text.isNotEmpty) {
                      List<Order>? list = await Database.getOrders(
                          context: context,
                          idSearch: tECSearch.text.trim(),
                          isPaying: true);
                      if (list != null) {
                        orders = list;
                        progress3 = false;
                        progress4 = false;
                      }
                    }
                    setState(() {
                      progress2 = false;
                    });
                  },
                ),
              SizedBox(height: SizeConfig().setHight(3)),
              orders.length < 2
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Expanded(child: widgetCheckBox()),
                        Text(
                          getPrices(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: color4),
                        ),
                      ],
                    ),
              if (orders.isEmpty)
                const SizedBox.shrink()
              else
                Column(
                  children: [
                    CustomGradientButton(
                      context: context,
                      text: "PAY",
                      func: () {
                        pay2();
                      },
                    ),
                    SizedBox(height: SizeConfig().setHight(3)),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return WidgetOrderTicket(
                          doubleTap: () {
                            doubleTap(index);
                          },
                          isBorder: selectedOrders.contains(orders[index]),
                          order: orders[index],
                          isCashier: true,
                          delete: () {
                            delete(index);
                          },
                          pay: () {
                            pay(orders[index], false);
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
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
                    role: "Cashier")
                .then((value) {
              if (value != null) {
                personnel = value;
              }
            });
            setState(() {
              progress1 = false;
            });
          });
    }
  }

  Theme widgetCheckBox() {
    return Theme(
      data: ThemeData(unselectedWidgetColor: color2),
      child: CheckboxListTile(
        value: cB1,
        checkColor: color4,
        activeColor: color2,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.all(0),
        title: const Text(
          "Select All",
          style: TextStyle(color: color4, fontWeight: FontWeight.bold),
        ),
        onChanged: (value) {
          if (value!) {
            selectedOrders = orders.toList();
          } else {
            selectedOrders = [];
          }
          setState(() {
            cB1 = value;
          });
        },
      ),
    );
  }

  //FUNCTİONS-----------

  void delete(int index) {
    SimpleUIs.showCustomDialog(
      context: context,
      activeCancelButton: true,
      title: "DELETE",
      content: const Text(
        "Do you want to delete the order?",
        style: TextStyle(color: color4),
      ),
      actions: [
        CustomGradientButton(
          context: context,
          text: "Delete",
          func: () {
            Navigator.pop(context);
            deleteOrder(index);
          },
        )
      ],
    );
  }

  Future deleteOrder(int index) async {
    SimpleUIs().showProgressIndicator(context);
    bool? response = await Database.deleteOrder(
        context: context, databaseReference: orders[index].databaseReference!);
    Navigator.pop(context);
    if (response ?? false) {
      setState(() {
        orders.removeAt(index);
        selectedOrders.removeWhere((element) => element.databaseReference==orders[index].databaseReference!);
      });
    }
  }

  Future pay2() async {
    if (selectedOrders.isEmpty) {
      Funcs().showSnackBar(context, "Pick orders you want to pay!");
    } else if (selectedOrders.length == 1) {
      pay(selectedOrders[0], false);
    } else {
      Order newOrder = Order.fromJson(selectedOrders[0].toMap());
      for (var i = 1; i < selectedOrders.length; i++) {
        newOrder.foods += selectedOrders[i].foods;
        newOrder.price += selectedOrders[i].price;
        newOrder.note += selectedOrders[i].note;
      }
      SimpleUIs.showCustomGeneralDialog(
        context: context,
        barrierDismissible: true,
        widget: Material(
          color: color1,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 30,
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig().setHight(3)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: WidgetOrderTicket(
                        order: newOrder,
                        isCashier: true,
                        delete: () {
                          Navigator.pop(context);
                        },
                        pay: () {
                          Navigator.pop(context);
                          pay(newOrder, true);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  String getPrices() {
    double price = 0;
    for (var item in selectedOrders) {
      price += item.price;
    }
    return Funcs().formatMoney(price);
  }

  void doubleTap(index) {
    if (selectedOrders.contains(orders[index])) {
      selectedOrders.removeWhere((element) => element == orders[index]);
    } else {
      selectedOrders.add(orders[index]);
    }
    checkCB();
    setState(() {});
  }

  void checkCB() {
    if (selectedOrders.length == orders.length) {
      cB1 = true;
    } else if (cB1 && selectedOrders.length != orders.length) {
      cB1 = false;
    }
  }

  void pay(Order orderValue, bool isMultiplePayment) {
    SimpleUIs.showCustomDialog(
      context: context,
      activeCancelButton: true,
      title: "PAY",
      content: const Text(
        "Do you want to pay the order?",
        style: TextStyle(color: color4),
      ),
      actions: [
        CustomGradientButton(
          context: context,
          text: "Pay",
          func: () {
            Navigator.pop(context);
            payOrder(orderValue,isMultiplePayment);
          },
        )
      ],
    );
  }

  Future payOrder(Order orderValue, bool isMultiplePayment) async {
    SimpleUIs().showProgressIndicator(context);
    if (!isMultiplePayment) {
      bool? isPaid = await Database.deleteOrder(
          context: context,
          databaseReference: orderValue.databaseReference!,
          isPaying: true);

      if (isPaid == null) {
        Navigator.pop(context);
        return;
      }

      if (isPaid) {
        bool isPaid2 =
            await Firestore.payOrder(context: context, order: orderValue);
        if (!isPaid2) {
          List list = Lists().box.get("paymentsWithError");
          list.add(orderValue);
          Lists().box.put("paymentsWithError", list);
        }

        selectedOrders.removeWhere((element) => element == orderValue);
        orders.removeWhere((element) => element == orderValue);

        if (orders.isEmpty) tECSearch.clear();
        checkCB();
        setState(() {});
      }
    } else {
      for (var element in selectedOrders) {
        //it wont come null from here because isCheckExist is false
        bool isPaid = await Database.deleteOrder(
                context: context,
                databaseReference: element.databaseReference!,
                isPaying: true,
                isCheckExist: false) ??
            false;
        if (isPaid) {
          orders.removeWhere((e) => e == element);
        }
      }

      selectedOrders
          .removeWhere((element) => orders.contains(element) == false);

      bool isPaid2 =
          await Firestore.payOrder(context: context, order: orderValue);
      if (!isPaid2) {
        List list = Lists().box.get("paymentsWithError") ?? [];
        list.add(orderValue);
        Lists().box.put("paymentsWithError", list);
      }
    }

    Navigator.pop(context);
    setState(() {});
  }

  void clear() {
    tECSearch.clear();
    setState(() {
      orders = [];
    });
  }
}
