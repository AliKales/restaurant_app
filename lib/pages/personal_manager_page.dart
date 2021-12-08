import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/pages/Admin%20Pages/admin_page.dart';
import 'package:restaurant_app/pages/Chef%20Pages/chef_page.dart';
import 'package:restaurant_app/pages/select_restaurant_page.dart';
import 'package:restaurant_app/pages/Staff%20Pages/staff_page.dart';
import 'package:restaurant_app/size.dart';

class PersonelManagerPage extends StatefulWidget {
  const PersonelManagerPage({Key? key}) : super(key: key);

  @override
  _PersonelManagerPageState createState() => _PersonelManagerPageState();
}

class _PersonelManagerPageState extends State<PersonelManagerPage>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  TextEditingController tECPasswordToExit = TextEditingController();

  Restaurant? restaurant;

  bool progress1=false;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    Timer(const Duration(milliseconds: 200),
        () => _animationController!.forward());
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      print("Send ");
      //FirebaseAuth.instance.currentUser!.sendEmailVerification();
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: color1,
        title: const Text("WHO ARE YOU?"),
        centerTitle: true,
        elevation: 1,
        actions: [
          // exit button
          InkWell(
            onTap: () {
              Funcs().showSnackBar(context, "'DOUBLE TAP' to exit");
            },
            onDoubleTap: () async {
              SimpleUIs.showCustomDialog(
                  context: context,
                  barriedDismissible: false,
                  onWillPop: false,
                  actions: [],
                  title: "Checking password..",
                  content: SimpleUIs().progressIndicator());
              restaurant = await Firestore().getRestaurant(context);
              Navigator.pop(context);
              if (restaurant == null) {
                return;
              } else if (restaurant!.password == "admin-code3152") {
                Funcs().navigatorPushReplacement(context, const SelectRestaurantPage());
              } else {
                await showGeneralDialog(
                  context: context,
                  barrierLabel: "Barrier",
                  barrierDismissible: false,
                  barrierColor: Colors.black.withOpacity(0.5),
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (_, __, ___) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: Material(
                        color: Colors.black.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(color: color4),
                                cursorColor: color4,
                                controller: tECPasswordToExit,
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: color4),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: color4),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: color4,
                                    size: 30,
                                  ),
                                  alignLabelWithHint: true,
                                  hintText: "Password to sign out",
                                  hintStyle: TextStyle(color: Colors.white60),
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(15),
                                ),
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical! * 6,
                              ),
                              CustomGradientButton(
                                context: context,
                                text: "SIGN OUT",
                                func: () {
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(
                                height: SizeConfig.safeBlockVertical! * 3,
                              ),
                              CustomGradientButton(
                                context: context,
                                text: "CANCEL",
                                isOutlined: true,
                                color: Colors.black.withOpacity(0.9),
                                func: () {
                                  tECPasswordToExit.text =
                                      "this is an admin code";
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                if (tECPasswordToExit.text == "this is an admin code") {
                  //here nothing special happens, just for cancel
                  tECPasswordToExit.clear();
                } else if (tECPasswordToExit.text.isEmpty) {
                  Funcs().showSnackBar(context, "Password can't be empty!");
                } else if (tECPasswordToExit.text == restaurant!.password) {
                  FirebaseAuth.instance.signOut().then((value) async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    Funcs().navigatorPushReplacement(
                        context, const SelectRestaurantPage());
                  }).onError((error, stackTrace) {
                    Funcs().showSnackBar(
                        context, "Unexpected error. Please try again!");
                  });
                } else {
                  Funcs().showSnackBar(context, "Wrong password!");
                }
                tECPasswordToExit.clear();
              }
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
      body: body(),
    );
  }

  Widget body() {
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      return Center(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(_animationController!),
          child: FadeTransition(
            opacity: _animationController!,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                widgetContainerForPerson("Staff", Icons.person, () {
                  Funcs().navigatorPushReplacement(context, const StaffPage());
                }),
                widgetContainerForPerson(
                    "Chef", Icons.fastfood, () {Funcs().navigatorPushReplacement(context, const ChefPage());}),
                widgetContainerForPerson(
                    "Admin", Icons.admin_panel_settings_rounded, () {
                  Funcs().navigatorPushReplacement(context, const AdminPage());
                }),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please verify your e-mail first!",
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(color: color4, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: SizeConfig().setHight(3)),
            CustomGradientButton(
              context: context,
              loading: progress1,
              text: "I did",
              func: () async {
                setState(() {
                  progress1=true;
                });
                await FirebaseAuth.instance.currentUser!.reload();
                if (!FirebaseAuth.instance.currentUser!.emailVerified) {
                  Funcs().showSnackBar(
                      context, "Please verify your e-mail first!");
                }
                setState(() {
                  progress1=false;
                });
              },
            )
          ],
        ),
      );
    }
  }

  dynamic widgetContainerForPerson(
      String text, IconData icon, Function() function) {
    return InkWell(
      onTap: function,
      child: Container(
        height: SizeConfig.safeBlockHorizontal! * 30,
        width: SizeConfig.safeBlockHorizontal! * 30,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)), color: color3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: color4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}