import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/login_page.dart';
import 'package:restaurant_app/UIs/order_ticket.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/order_status.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/pages/personal_manager_page.dart';
import 'package:restaurant_app/size.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'previous_orders_page.dart';
import 'add_food_page.dart';

class WaiterPage extends StatefulWidget {
  const WaiterPage({Key? key}) : super(key: key);

  @override
  _WaiterPageState createState() => _WaiterPageState();
}

class _WaiterPageState extends State<WaiterPage> {
  final formatCurrency = NumberFormat.simpleCurrency();
  Personnel? personnel;

  TextEditingController tECPassword = TextEditingController();
  TextEditingController tECUsername = TextEditingController();
  TextEditingController tECID = TextEditingController();
  TextEditingController tECNote = TextEditingController();

  var box = Hive.box('database');

  bool progress1 = false;
  bool progress2 = false;

  ///* [progress3] note page
  bool progress3 = false;

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
      body: Stack(
        children: [
          widgetBody(context),
          Visibility(visible: progress3, child: widgetNotePage(context))
        ],
      ),
    );
  }

  Container widgetNotePage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                  maxLine: null,
                  textEditingController: tECNote,
                  text: "Note",
                  iconData: Icons.note_add),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomGradientButton(
                    context: context,
                    text: "Close",
                    color: Colors.black.withOpacity(0.95),
                    isOutlined: true,
                    func: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        progress3 = false;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InkWell widgetBody(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: body(),
    );
  }

  body() {
    //has not logged in yet as Staff
    if (personnel == null) {
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
                  role: "Staff")
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
                longPress: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    progress3 = true;
                  });
                },
                inkWellOnTap: (index) {
                  countChanger(index);
                },
                add: () {
                  FocusScope.of(context).unfocus();
                  addFood();
                },
                funcOrder: () {
                  FocusScope.of(context).unfocus();
                  funcOrder(false);
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
    clear();
  }

  Future funcOrder(bool sendAnyway) async {
    if (tECID.text.trim().isEmpty || foods.isEmpty) {
      Funcs().showSnackBar(context, "ID/Name and Foods can not be empty!");
      return;
    }
    List list = [];
    for (var item in foods) {
      list.add(item.toMap());
    }
    String? databaseReference = await Funcs.createId(
        context: context, personnelUsername: personnel!.username);
    order = Order(
        note: tECNote.text.trim(),
        orderBy: tECUsername.text,
        date: DateTime.now().toIso8601String(),
        id: tECID.text.trim(),
        foods: list,
        price: getTotalAmount(),
        databaseReference: databaseReference,
        idSearch: tECID.text.trim().replaceAll(" ", ""),
        status: OrderStatus.waiting);

    SimpleUIs().showProgressIndicator(context);
    String value = await Database().sendOrder(context, order!, sendAnyway);
    if (value == "admin-code-31") {
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
              func: (){
                Funcs().showSnackBar(context, "LONG PRESS!!!!");
              },
              longPress: () {
                Navigator.pop(context);
                funcOrder(true);
              },
            )
          ]);
      return;
    } else if (value != "") {
      orders.insert(0, order);
      box.put("orders", orders);
      clear();
    } else {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);
  }

  void clear() {
    setState(() {
      order = null;
      foods.clear();
      tECID.clear();
      tECNote.clear();
    });
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