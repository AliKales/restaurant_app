import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/order_ticket.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/pages/Staff%20Pages/add_food_page.dart';
import 'package:restaurant_app/pages/Staff%20Pages/previous_orders_page.dart';
import 'package:restaurant_app/pages/personal_manager_page.dart';
import 'package:restaurant_app/size.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({Key? key}) : super(key: key);

  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final formatCurrency = NumberFormat.simpleCurrency();
  Personnel? personnel;

  TextEditingController tECPassword = TextEditingController();
  TextEditingController tECUsername = TextEditingController();
  TextEditingController tECID = TextEditingController();

  var box = Hive.box('database');

  bool progress1 = false;
  bool progress2 = false;

  List<Food> foods = [];
  List orders = [];

  Order? order;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orders = box.get("orders") ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppbarForPersons(
        text: "Staff",
        actions: [
          Visibility(
            visible: personnel != null,
            child: IconButton(
              onPressed: () async {
                var value = await Funcs().navigatorPush(
                  context,
                  PreviousOrdersPage(
                    orders: orders,
                  ),
                );
                if (value != null) {
                  orders = value;
                }
              },
              padding: const EdgeInsets.only(right: 15),
              icon: const Icon(
                Icons.list_alt_outlined,
                color: color4,
              ),
            ),
          ),
          Visibility(
            visible: personnel != null,
            child: IconButton(
              onPressed: () {
                SimpleUIs.showCustomDialog(
                  context: context,
                  title: "UPDATES",
                  content: Text(
                    "Get updates?",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: color4),
                  ),
                  actions: [
                    CustomGradientButton(
                      context: context,
                      text: "No",
                      isOutlined: true,
                      color: color1,
                      func: () {
                        Navigator.pop(context);
                      },
                    ),
                    CustomGradientButton(
                      context: context,
                      text: "Yes",
                      func: () async {
                        Navigator.pop(context);
                        setState(() {
                          progress2 = true;
                        });
                        await Lists().getUpdatedFoodsAndCategories(context);
                        setState(() {
                          progress2 = false;
                        });
                      },
                    ),
                  ],
                );
              },
              padding: const EdgeInsets.only(right: 15),
              icon: const Icon(
                Icons.download,
                color: color4,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Funcs().showSnackBar(context, "'DOUBLE TAP' to exit");
            },
            onDoubleTap: () {
              Funcs().navigatorPushReplacement(
                  context, const PersonelManagerPage());
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.exit_to_app_rounded,
                color: color4,
              ),
            ),
          ),
        ],
      ),
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: body(),
      ),
    );
  }

  body() {
    //has not logged in yet as Staff
    if (personnel == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 20,
            ),
            //username
            CustomTextField(
                textEditingController: tECUsername,
                text: "Staff Username",
                iconData: Icons.person),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 3,
            ),
            //password
            CustomTextField(
              textEditingController: tECPassword,
              text: "Staff Password",
              iconData: Icons.lock_outline,
            ),
            SizedBox(
              height: SizeConfig.safeBlockVertical! * 6,
            ),
            // Log in
            CustomGradientButton(
              context: context,
              text: "LOG IN",
              loading: progress1,
              func: () async {
                setState(() {
                  progress1 = true;
                });
                FocusScope.of(context).unfocus();
                await Firestore.logInStaff(
                        context: context,
                        username: tECUsername.text,
                        password: tECPassword.text)
                    .then((value) {
                  if (value != null) {
                    personnel = value;
                    getLists();
                  }
                });
                setState(() {
                  progress1 = false;
                });
              },
            )
          ],
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                personnel!.restaurantName,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: color4, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  color: Colors.grey[850],
                  thickness: 1,
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "  - ${personnel!.name}",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: color4, fontWeight: FontWeight.bold),
                ),
              ),
              OrderTicket(
                tECID: tECID,
                foods: foods,
                price: getTotalAmount(),
                inkWellOnTap: (index) {
                  countChanger(index);
                },
                add: () {
                  FocusScope.of(context).unfocus();
                  addFood();
                },
                funcOrder: () {
                  FocusScope.of(context).unfocus();
                  funcOrder();
                },
                funcDelete: () {
                  FocusScope.of(context).unfocus();
                  funcDelete();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  //FUNCTİONSSSSSSS

  Future addFood() async {
    var value = await Funcs().navigatorPush(
      context,
      AddFoodPage(
        pickedFoods: foods,
      ),
    );
    if (value != null) {
      setState(() {
        foods += value;
      });
    }
  }

  void funcDelete() {
    for (var food in foods) {
      food.count = 1;
    }
    setState(() {
      foods.clear();
      tECID.clear();
    });
  }

  Future funcOrder() async {
    if (tECID.text.trim().isEmpty || foods.isEmpty) {
      Funcs().showSnackBar(context, "ID/Name and Foods can not be empty!");
      return;
    }
    List list = [];
    for (var item in foods) {
      list.add(item.toMap());
    }
    order ??= Order(
        orderBy: tECUsername.text,
        date: DateTime.now().toIso8601String(),
        id: tECID.text.trim(),
        foods: list,
        price: getTotalAmount(),
        databaseReference: "",
        idSearch: tECID.text.trim().replaceAll(" ", ""));

    SimpleUIs().showProgressIndicator(context);
    String value = await Database().sendOrder(context, order!.toMap());
    if (value != "") {
      order!.databaseReference = value;
    } else {
      return;
    }
    bool boolean = await Firestore.setOrder(context: context, order: order!);
    if (!boolean) {
      return;
    } else {
      Navigator.pop(context);
      orders.insert(0, order);
      box.put("orders", orders);
      setState(() {
        order = null;
        foods.clear();
        tECID.clear();
      });
    }
  }

  getLists() async {
    setState(() {
      progress2 = true;
    });
    await Lists().getFoodsAndCategories(context);
    setState(() {
      progress2 = false;
    });
  }

  double getTotalAmount() {
    double amount = 0;
    for (var food in foods) {
      amount += double.parse(food.price) * food.count;
    }
    return amount;
  }

  List listForDialog = [];

  Future countChanger(int index) async {
    listForDialog = [];
    for (var i = 0; i < 51; i++) {
      listForDialog.add(i);
    }

    var value = await SimpleUIs()
        .showGeneralDialogFunc(context, listForDialog, foods[index].count);
    if (value == 0) {
      foods[index].count = 1;
      setState(() {
        foods.removeWhere((element) => element == foods[index]);
      });
    } else {
      setState(() {
        foods[index].count = value;
      });
    }
  }
}
