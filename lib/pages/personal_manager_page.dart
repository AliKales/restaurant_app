import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/pages/Admin%20Pages/admin_page.dart';
import 'package:restaurant_app/pages/Cashier%20Pages/cashier_page.dart';
import 'package:restaurant_app/pages/Chef%20Pages/chef_page.dart';
import 'package:restaurant_app/pages/Waiter%20Pages/waiter_page.dart';
import 'package:restaurant_app/pages/select_restaurant_page.dart';
import 'package:restaurant_app/size.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

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
  Map? policiesFromDB;

  bool progress1 = false;
  bool progress2 = false;
  bool progress3 = false;

  bool permission1 = false;

  bool canNext = true;

  bool isPolicy = false;

  ///* [permission2] is for version check
  bool? permission2;

  var box = Hive.box('database');

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    Timer(const Duration(milliseconds: 200),
        () => _animationController!.forward());
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
    }
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => getRestaurantInfosAndCheckPolicies());
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
        appBar: AppbarForPersons(
          text: "WHO ARE YOU?",
          onDoubleTap: () async {
            if (restaurant == null ||
                restaurant!.password == "ozel-admin-code:31") {
              await signOut();
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
                                hintText: "Admin password to sign out",
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
                await signOut();
              } else {
                Funcs().showSnackBar(context, "Wrong password!");
              }
              tECPasswordToExit.clear();
            }
          },
        ),
        body: body());
  }

  List persons = [
    {
      "text": "Waiter",
      "icon": Icons.person,
      "page": const WaiterPage(),
    },
    {
      "text": "Chef",
      "icon": Icons.fastfood,
      "page": const ChefPage(),
    },
    {
      "text": "Cashier",
      "icon": Icons.attach_money_rounded,
      "page": const CashierPage(),
    },
    {
      "text": "Admin",
      "icon": Icons.admin_panel_settings_rounded,
      "page": const AdminPage(
        isPaid: true,
      ),
    },
  ];

  Widget body() {
    if (isPolicy) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Before you continue to use, you have to agree to "Privacy Policy" and "Terms and Conditions"',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          SimpleUIs().widgetWithProgress(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      progress3 = true;
                    });
                    bool? result =
                        await Funcs().getPolicies("privacy", context);
                    if (result != null) {
                      canNext = false;
                    } else {
                      canNext = true;
                    }
                    setState(() {
                      progress3 = false;
                    });
                  },
                  child: const Text(
                    "Privacy Policy",
                    style: TextStyle(color: color2),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      progress3 = true;
                    });
                    bool? result = await Funcs().getPolicies("terms", context);
                    if (result != null) {
                      canNext = false;
                    } else {
                      canNext = true;
                    }
                    setState(() {
                      progress3 = false;
                    });
                  },
                  child: const Text(
                    "Terms and Conditions",
                    style: TextStyle(color: color2),
                  ),
                ),
              ],
            ),
            progress3,
          ),
          CustomGradientButton(
            context: context,
            text: "I AGREE",
            func: () {
              if (!canNext) {
                Funcs().showSnackBar(context,
                    'First you have to read the "Privacy Policy" and "Terms & Conditions"');
                return;
              }
              box.put("policies", policiesFromDB);
              setState(() {
                isPolicy = false;
              });
              getRestaurantInfos();
            },
          ),
        ],
      );
    }
    if (permission2 != null && !permission2!) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "PLEASE UPDATE THE APP ON GOOGLE PLAY STORE!!!",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          CustomGradientButton(
            context: context,
            text: "Update",
            func: () async {
              if (!await launch(
                  "https://play.google.com/store/apps/details?id=com.caroby.q_biks")) {
                Funcs().showSnackBar(context,
                    "Error! Please update manually on Google Play Store");
              }
            },
          )
        ],
      );
    }
    if (progress2) {
      return Center(
        child: CustomGradientButton(
          context: context,
          text: "TRY AGAIN",
          func: () {
            getRestaurantInfosAndCheckPolicies();
          },
        ),
      );
    }
    if (restaurant == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "RESTAURANT INFOS ARE GETTING..",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          SimpleUIs().progressIndicator(),
        ],
      );
    } else {
      return Center(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(_animationController!),
          child: FadeTransition(
            opacity: _animationController!,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: persons.length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kIsWeb ? 4 : 2,
                    mainAxisSpacing: SizeConfig().setHight(5),
                    crossAxisSpacing: SizeConfig().setWidth(5)),
                itemBuilder: (context, index) {
                  return kIsWeb &&
                          (persons[index]['text'] == "Admin" ||
                              persons[index]['text'] == "Waiter")
                      ? const SizedBox.shrink()
                      : widgetContainerForPerson(persons[index]);
                },
              ),
            ),
          ),
        ),
      );
    }
    //else {
    //   return Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Text(
    //             "Please verify your e-mail first!\nWe sent you an e-mail to verify your account.\nDon't forget the check your Junk E-Mails.",
    //             style: Theme.of(context)
    //                 .textTheme
    //                 .headline5!
    //                 .copyWith(color: color4, fontWeight: FontWeight.bold),
    //             textAlign: TextAlign.left,
    //           ),
    //         ),
    //         SizedBox(height: SizeConfig().setHight(3)),
    //         CustomGradientButton(
    //           context: context,
    //           loading: progress1,
    //           text: "I did",
    //           func: () async {
    //             setState(() {
    //               progress1 = true;
    //             });
    //             await FirebaseAuth.instance.currentUser!.reload();
    //             if (!FirebaseAuth.instance.currentUser!.emailVerified) {
    //               Funcs().showSnackBar(
    //                   context, "Please verify your e-mail first!");
    //             }
    //             setState(() {
    //               progress1 = false;
    //             });
    //           },
    //         )
    //       ],
    //     ),
    //   );
    // }
  }

  dynamic widgetContainerForPerson(Map map) {
    return InkWell(
      onTap: () {
        if (permission1) {
          Funcs().navigatorPushReplacement(context, map['page']);
        } else {
          if (map['text'] == "Admin") {
            Funcs().navigatorPushReplacement(
                context,
                const AdminPage(
                  isPaid: false,
                ));
          } else {
            Funcs().showSnackBar(context, "Please Pay To Keep Using!!!");
          }
        }
      },
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
                  map['icon'],
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                map['text'],
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: color4, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future signOut() async {
    FirebaseAuth.instance.signOut().then((value) async {
      await Future.delayed(const Duration(milliseconds: 500));
      Funcs().navigatorPushReplacement(context, const SelectRestaurantPage());
    }).onError((error, stackTrace) {
      Funcs().showSnackBar(context, "Unexpected error. Please try again!");
    });
  }

  //FUNCTIONSSSSSSSSSSSSSSSSSSSSSSS
  Future getRestaurantInfosAndCheckPolicies() async {
    setState(() {
      progress2 = false;
    });
    //CheckPolicies
    Map? policies = box.get("policies");
    policiesFromDB = await Firestore().getPolicies(context);
    if (policiesFromDB == null) {
      setState(() {
        progress2 = true;
      });
      Funcs().showSnackBar(context, "ERROR");
      return;
    } else if (policies == null ||
        policies['update'] != policiesFromDB!['update']) {
      box.put("policies", policies);
      setState(() {
        isPolicy = true;
      });
      return;
    }
    getRestaurantInfos();
  }

  Future getRestaurantInfos() async {
    if (!kIsWeb) {
      bool? response = await Firestore().checkVersion(context);
      if (response == null) {
        setState(() {
          progress2 = true;
        });
        return;
      } else if (response == false) {
        setState(() {
          permission2 = false;
        });
        return;
      } else {
        permission2 = true;
      }
    } else {
      permission2 = true;
    }

    Map map = box.get('infoRestaurant') ?? {};
    if (map.isNotEmpty &&
        DateTime.parse(map['dateTime']).day == DateTime.now().day) {
      restaurant = map['restaurant'];
      permission1 = true;
    } else {
      setState(() {
        progress2 = false;
      });
      restaurant = await Firestore().getRestaurant(context);
      if (restaurant == null) {
        progress2 = true;
      }
      if (kIsWeb) {
        permission1 = true;
      } else if (restaurant != null &&
          restaurant!.password != "ozel-admin-code:31") {
        await Funcs()
            .getCurrentGlobalTimeForRestaurantCreating(context)
            .then((value) {
          if (value != null) {
            DateTime paymentDate = DateTime.parse(restaurant!.paymentDate);
            int howManyDays = paymentDate.difference(value).inDays;
            if (howManyDays > 0) {
              permission1 = true;
              box.put("infoRestaurant", {
                'dateTime': DateTime.now().toIso8601String(),
                'restaurant': restaurant
              });
            }
          } else {
            progress2 = true;
          }
        });
      }
    }

    setState(() {
      box.put("restaurant", restaurant);
    });
  }
}
