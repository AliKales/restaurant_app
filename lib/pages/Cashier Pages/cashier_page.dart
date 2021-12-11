import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/login_page.dart';
import 'package:restaurant_app/UIs/order_ticket.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/size.dart';

import '../../models/food.dart';

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

  Order? order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarForPersons(
        text: "Cashier",
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
    if (personnel != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomTextField(
              textEditingController: tECSearch,
              text: "ID for Search",
            ),
            SizedBox(height: SizeConfig().setHight(3)),
            if (order != null)
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
                  });
                  if (tECSearch.text.isNotEmpty) {
                    var value = await Firestore.getOrder(
                        context: context, idSearch: tECSearch.text.trim());
                    if (value != null) {
                      order = value;
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
            if (order == null)
              const SizedBox.shrink()
            else
              Expanded(
                child: Slidable(
                  key: const ValueKey(5),
                  // The start action pane is the one at the left or the top side.
                  startActionPane: progress4
                      ? null
                      : ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),
                          children: [
                            // A SlidableAction can have an icon and/or a label.
                            SlidableAction(
                              onPressed: (contextt) async {
                                SimpleUIs().showProgressIndicator(context);
                                await Firestore.deleteOrder(
                                        context: context,
                                        showMessage: true,
                                        databaseReference:
                                            order!.databaseReference!)
                                    .then((value) {
                                  if (value) {
                                    progress4 = true;
                                  }
                                });
                                Navigator.pop(context);
                                setState(() {});
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),

                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: progress3
                      ? null
                      : ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              // An action can be bigger than the others.
                              onPressed: (contextt) async {
                                SimpleUIs().showProgressIndicator(context);
                                await Firestore.payOrder(
                                        context: context, order: order!)
                                    .then((value) {
                                  if (value) {
                                    progress3 = true;
                                  }
                                });
                                Navigator.pop(context);
                                setState(() {});
                              },
                              backgroundColor: Color(0xFF7BC043),
                              foregroundColor: Colors.white,
                              icon: Icons.payment,
                              label: 'Pay',
                            ),
                          ],
                        ),
                  child: ChildOrderTicket(
                    noTouch: true,
                    price: order!.price!,
                    foods: List<Food>.generate(order!.foods!.length,
                        (index) => Food.fromJson(order!.foods![index])),
                    inkWellOnTap: (index) {},
                  ),
                ),
              ),
          ],
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

  //FUNCTİONS-----------

  void clear() {
    tECSearch.clear();
    setState(() {
      order = null;
    });
  }
}
