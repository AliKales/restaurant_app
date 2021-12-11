import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/personnel_ui.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/pages/Admin%20Pages/food_categories_page.dart';
import 'package:restaurant_app/pages/Admin%20Pages/food_menu_page.dart';
import 'package:restaurant_app/pages/Admin%20Pages/new_personnel_page.dart';
import 'package:restaurant_app/pages/Admin%20Pages/add_new_personal.dart';
import 'package:restaurant_app/pages/Admin%20Pages/statisticks_page.dart';
import 'package:restaurant_app/pages/payment_page.dart';
import 'package:restaurant_app/pages/personal_manager_page.dart';
import 'package:restaurant_app/pages/remove_update_page.dart';
import 'package:restaurant_app/pages/select_restaurant_page.dart';
import 'package:restaurant_app/size.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

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

  int drawerTappedIndex = 0;

  Builders builder = Builders.loading;

  var box = Hive.box('database');

  Restaurant? restaurant;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => futureBuilder());
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
      return Text("HATA");
    } else if (builder == Builders.noData) {
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
            "It seems like you haven't payed yet. If you want to keep using this app, you have to pay. You will pay once a month for opening a 'Restaurant'.",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 5,
          ),
          CustomGradientButton(
            context: context,
            text: "PAY",
            func: () {
              Funcs().navigatorPush(context, const PaymentPage()).then((value) {
                if (value) {
                  futureBuilder();
                }
              });
            },
          )
        ],
      ),
    );
  }

  ////////////////////////////////FUNCTIONS HERE/////////////

  //HERE func for Personnels from database

  void drawerTapped(int index) {
    setState(() {
      drawerTappedIndex = index;
      pageController.jumpToPage(index);
    });
  }
}
