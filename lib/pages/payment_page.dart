import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/size.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController tECEUsername = TextEditingController();
  TextEditingController tECPassword = TextEditingController();
  TextEditingController tECRestaurantName = TextEditingController();

  ScrollController scrollController = ScrollController();

  bool progress1 = false;

  var box = Hive.box('database');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color1,
        title: const Text("Payment"),
        centerTitle: true,
        elevation: 1,
      ),
      body: body(),
    );
  }

  body() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              //Info
              Text(
                "On this page, you are going to set a 'username' and 'password' for 'Owner' page. Please do not use the same password which you used while creating this account and do not share your password!",
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: color4, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 5,
              ),
              //Username
              CustomTextField(
                textEditingController: tECEUsername,
                text: "Username",
                iconData: Icons.person,
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              //Password
              CustomTextField(
                textEditingController: tECPassword,
                text: "Password",
                iconData: Icons.lock_outline,
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              //Restaurant Name
              CustomTextField(
                textEditingController: tECRestaurantName,
                text: "Restaurant Name",
                iconData: Icons.food_bank,
                function: () async {
                  await Future.delayed(const Duration(milliseconds: 200));
                  scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);
                },
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 6,
              ),
              CustomGradientButton(
                context: context,
                loading: progress1,
                text: "Pay",
                func: () async {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    progress1 = true;
                  });
                  await Funcs()
                      .usernameAndPasswordChecker(
                          tECEUsername.text, tECPassword.text)
                      .then((value) {
                    if (value != "") {
                      setState(() {
                        progress1 = false;
                      });
                      Funcs().showSnackBar(context, value);
                    } else if (tECRestaurantName.text.isEmpty) {
                      setState(() {
                        progress1 = false;
                      });
                      Funcs().showSnackBar(
                          context, "Restaurant Name can't be empty!");
                    } else {
                      Funcs().getCurrentGlobalTime(context).then((value) {
                        Firestore()
                            .createARestaurant(
                          Restaurant(
                            username: tECEUsername.text.trim(),
                            password: tECPassword.text.trim(),
                            restaurantName: tECRestaurantName.text.trim(),
                            createdTime: value.toIso8601String(),
                            email: Auth().getEMail(),
                          ),
                        )
                            .then((value) {
                          setState(() {
                            progress1 = false;
                          });
                          if (value.runtimeType == Restaurant) {
                            box.put("restaurant", value);
                            Funcs().showSnackBar(
                                context, "Your resaurant is ready.");
                            Navigator.pop(context, true);
                          } else {
                            Funcs().showSnackBar(
                                context, "Error, try again later.");
                          }
                        });
                      });
                    }
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
