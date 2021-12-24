import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/pages/Admin%20Pages/food_categories_page.dart';
import 'package:restaurant_app/pages/Admin%20Pages/food_menu_page.dart';
import 'package:restaurant_app/pages/Admin%20Pages/new_personnel_page.dart';
import 'package:restaurant_app/pages/Admin%20Pages/statisticks_page.dart';
import 'package:restaurant_app/pages/payment_page.dart';
import 'package:restaurant_app/size.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key, required this.isPaid}) : super(key: key);
  final bool isPaid;

  @override
  _AdminPageState createState() => _AdminPageState();
}

enum Builders { loading, hasError, noData, done }

class _AdminPageState extends State<AdminPage> {
  CollectionReference reference =
      FirebaseFirestore.instance.collection('restaurants');

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  bool progress1 = false;
  bool progress2 = false;
  bool progress3 = false;

  bool paymentForMoreDays = false;

  int drawerTappedIndex = 0;

  Builders builder = Builders.loading;

  var box = Hive.box('database');

  Restaurant? restaurant;
  Restaurant? valueRestaurant;

  StreamSubscription? _subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription!.cancel();
    }, onError: (error) {
      setState(() {
        progress2 = false;
      });
      Funcs().showSnackBar(context, "Error, try again later.");
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) => futureBuilder());
  }

  @override
  void dispose() {
    _subscription!.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.canceled) {
        setState(() {
          progress2 = false;
        });
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        setState(() {
          progress2 = false;
        });
        Funcs().showSnackBar(context, "ERROR");
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        if (purchaseDetails.pendingCompletePurchase) {
          if (paymentForMoreDays) {
            Firestore().updateRestaurant(context, {
              'paymentDate': DateTime.parse(valueRestaurant!.paymentDate)
                  .add(const Duration(days: 30))
                  .toIso8601String()
            }).then((value) async {
              if (value) {
                await InAppPurchase.instance
                    .completePurchase(purchaseDetails)
                    .then((v) {
                  valueRestaurant!.paymentDate =
                      DateTime.parse(valueRestaurant!.paymentDate)
                          .add(const Duration(days: 30))
                          .toIso8601String();
                  restaurant = valueRestaurant;
                  box.put("restaurant", valueRestaurant);
                  Funcs().showSnackBar(
                      context, "Your payment has been successfully received.");
                  setState(() {
                    progress3 = false;
                    paymentForMoreDays = false;
                  });
                }).onError((error, stackTrace) async {
                  await Firestore().updateRestaurant(context, {
                    'paymentDate': DateTime.parse(valueRestaurant!.paymentDate)
                        .subtract(const Duration(days: 30))
                        .toIso8601String()
                  });
                  setState(() {
                    progress3 = false;
                  });
                  showErrorMessage();
                });
              } else {
                setState(() {
                  progress3 = false;
                });
                showErrorMessage();
              }
            });
          } else {
            Firestore().createARestaurant(valueRestaurant!).then((value) async {
              if (value.runtimeType == Restaurant) {
                await InAppPurchase.instance
                    .completePurchase(purchaseDetails)
                    .then((v) {
                  box.put("restaurant", value);
                  Funcs().showSnackBar(context, "Your resaurant is ready.");
                  futureBuilder();
                }).onError((error, stackTrace) async {
                  await Firestore().deleteRestaurant(context);
                  showErrorMessage();
                });
              } else {
                setState(() {
                  progress2 = false;
                });
                Funcs().showSnackBar(context, "Error, try again later.");
                showErrorMessage();
              }
            });
          }
        }
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        print("RESTORED");
      }
    });
  }

  Future futureBuilder() async {
    try {
      var valueFromHive = box.get("restaurant") ?? false;
      //if no restaurant saved before then it returns false and it checks from database
      if (valueFromHive == false) {
        await reference
            .doc(Auth().getEMail())
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            setState(() {
              restaurant = Restaurant.fromJson(documentSnapshot.data() as Map);
              builder = Builders.done;
            });
          } else {
            setState(() {
              builder = Builders.noData;
            });
          }
        });
      } else {
        await reference
            .where('email', isEqualTo: valueFromHive.email)
            .where('password', isNotEqualTo: valueFromHive.password)
            .get()
            .then((value) {
          //if its empty that means password havent changed yet since its logged in
          if (value.docs.isEmpty) {
            setState(() {
              restaurant = valueFromHive;
              builder = Builders.done;
            });
          } else {
            //if its not empty that means passwords has changed so here we get new data from database
            for (var element in value.docs) {
              setState(() {
                restaurant = Restaurant.fromJson(element.data() as Map);
                box.put("restaurant", restaurant);
                builder = Builders.done;
              });
            }
          }
        }).catchError((e) {
          print(e);
        });
      }
    } catch (e) {
      setState(() {
        builder = Builders.hasError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarForPersons(text: "Admin"),
      onDrawerChanged: (boolen) {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      drawer: !progress1
          ? null
          : Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 2,
              decoration: const BoxDecoration(
                  color: color1,
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(8))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetRowOnDrawer(0, "PERSONNELS"),
                  widgetSperaterForDrawer(),
                  widgetRowOnDrawer(1, "FOOD MENU"),
                  widgetSperaterForDrawer(),
                  widgetRowOnDrawer(2, "FOOD CATEGORIES"),
                  widgetSperaterForDrawer(),
                  widgetRowOnDrawer(3, "STATISTICKS")
                ],
              ),
            ),
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          final FocusScopeNode currentScope = FocusScope.of(context);
          if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
            FocusManager.instance.primaryFocus!.unfocus();
          }
        },
        child: body(),
      ),
    );
  }

  Widget widgetSperaterForDrawer() {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig().setHight(2),
        ),
        Divider(
          color: Colors.grey[350],
        ),
        SizedBox(
          height: SizeConfig().setHight(2),
        ),
      ],
    );
  }

  Widget widgetRowOnDrawer(int index, String text) {
    return InkWell(
      onTap: () {
        if (index != drawerTappedIndex) {
          Navigator.pop(context);
          drawerTapped(index);
        }
      },
      child: Row(
        children: [
          Icon(
            drawerTappedIndex == index
                ? Icons.arrow_downward_rounded
                : Icons.arrow_forward_sharp,
            color: Colors.white,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                color: drawerTappedIndex == index ? color2 : color4,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  body() {
    if (builder == Builders.loading) {
      return SimpleUIs().progressIndicator();
    } else if (builder == Builders.hasError) {
      return Center(
          child: Text(
        "ERROR! TRY AGAIN",
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
      ));
    } else if (builder == Builders.noData ||
        !widget.isPaid ||
        paymentForMoreDays) {
      return widgetMustBuy(context);
    } else {
      return buildPageView();
    }
  }

  PageView buildPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      children: [
        NewPersonnelPage(
          restaurant: restaurant!,
          logedIn: () {
            setState(() {
              progress1 = true;
            });
          },
          goToPayment: () {
            setState(() {
              paymentForMoreDays = true;
            });
          },
        ),
        FoodMenuPage(restaurant: restaurant!),
        FoodCategoriesPage(restaurant: restaurant!),
        StatisticksPage(restaurant: restaurant!)
      ],
    );
  }

  //Widget Tree when he hasnt payed
  Widget widgetMustBuy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            paymentForMoreDays
                ? "You can pay here to get access for another 30 days."
                : "It seems like you haven't payed yet. If you want to keep using this app, you have to pay. You have to pay once a month.",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 5,
          ),
          SimpleUIs().widgetWithProgress(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Visibility(
                  visible: paymentForMoreDays,
                  child: CustomGradientButton(
                    context: context,
                    text: "CANCEL",
                    color: color1,
                    isOutlined: true,
                    func: () {
                      setState(() {
                        paymentForMoreDays = false;
                      });
                    },
                  ),
                ),
                CustomGradientButton(
                  context: context,
                  text: "PAY",
                  loading: progress2,
                  func: () async {
                    pay();
                  },
                ),
              ],
            ),
            progress3,
          ),
        ],
      ),
    );
  }

  ////////////////////////////////FUNCTIONS HERE/////////////

  //HERE func for Personnels from database

  void showErrorMessage() {
    SimpleUIs.showCustomDialog(
        context: context,
        title: "ERROR!",
        actions: [
          CustomGradientButton(
            context: context,
            text: "Copy Mail",
            func: () {
              Clipboard.setData(
                  ClipboardData(text: "suggestionsandhelp@hotmail.com"));
              Funcs().showSnackBar(context, "E-Mail copied");
            },
          ),
          CustomGradientButton(
            context: context,
            text: "Copy Instagram",
            func: () {
              Clipboard.setData(ClipboardData(text: "caroby2"));
              Funcs().showSnackBar(context, "Instagram copied");
            },
          )
        ],
        content: Text(
            "Unexpected ERROR. Please check if you paid or not. If you have already paid and you saw an ERROR, please contact us via E-Mail or Instagram\nE-mail: suggestionsandhelp@hotmail.com\nInstagram: caroby2",
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: color4, fontWeight: FontWeight.bold)));
  }

  Future pay() async {
    if (paymentForMoreDays) {
      setState(() {
        progress3 = true;
      });
      await Firestore().getRestaurant(context).then((value) {
        if (value != null && value.password != "ozel-admin-code:31") {
          pay2(value);
        } else {
          setState(() {
            progress3 = false;
          });
        }
      });
    } else {
      Funcs().navigatorPush(context, const PaymentPage()).then((value) async {
        pay2(value);
      });
    }
  }

  Future pay2(value) async {
    if (value.runtimeType == Restaurant) {
      setState(() {
        progress2 = true;
      });
      valueRestaurant = value;
      const Set<String> _kIds = <String>{'deneme'};
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        // Handle the error.
      }
      List<ProductDetails> products = response.productDetails;

      final ProductDetails productDetails =
          products[0]; // Saved earlier from queryProductDetails().

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  void drawerTapped(int index) {
    setState(() {
      drawerTappedIndex = index;
      pageController.jumpToPage(index);
    });
  }
}
