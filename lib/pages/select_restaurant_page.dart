import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/pages/personal_manager_page.dart';
import 'package:restaurant_app/size.dart';
import 'package:hive/hive.dart';

class SelectRestaurantPage extends StatefulWidget {
  const SelectRestaurantPage({Key? key}) : super(key: key);

  @override
  _SelectRestaurantPageState createState() => _SelectRestaurantPageState();
}

class _SelectRestaurantPageState extends State<SelectRestaurantPage> {
  bool progress1 = false;
  bool isPasswordNotShown = true;
  bool? isLoggedIn;
  TextEditingController tECEMail = TextEditingController();
  TextEditingController tECPassword = TextEditingController();
  var box = Hive.box('database');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) => listeners());
  }

  void listeners() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          isLoggedIn = false;
        });
      } else {
        setState(() {
          isLoggedIn = true;
        });

        goToPersonalManagerPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widgetMain(context);

  Listener widgetMain(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          future: SizeConfig().init(context),
          builder: (context, AsyncSnapshot<void> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: SimpleUIs().progressIndicator(),
              );
            } else {
              if (isLoggedIn == null) {
                return Center(
                  child: SimpleUIs().progressIndicator(),
                );
              } else if (isLoggedIn!) {
                return Center(
                  child: SimpleUIs().progressIndicator(),
                );
              } else {
                if (kIsWeb) {
                  return SingleChildScrollView(child: body());
                } else {
                  return body();
                }
              }
            }
          },
        ),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //E-Mail
          CustomTextField(
            textEditingController: tECEMail,
            text: "E-Mail",
            iconData: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 3,
          ),
          //Password
          CustomTextField(
            textEditingController: tECPassword,
            text: "Password",
            iconData: Icons.lock_outline,
            obscureText: isPasswordNotShown,
            suffixIconFunction: () {
              setState(() {
                isPasswordNotShown = !isPasswordNotShown;
              });
            },
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 6,
          ),
          // Progress1 loading
          Visibility(
            visible: progress1,
            child: SimpleUIs().progressIndicator(),
          ),
          // LOG IN Button
          Visibility(
              visible: !progress1,
              child: CustomGradientButton(
                context: context,
                text: "LOG IN",
                func: () {
                  setState(() {
                    progress1 = true;
                  });
                  //if returns true, it means its logged in
                  Auth()
                      .signInWithEmail(tECEMail.text, tECPassword.text, context)
                      .then((value) {
                    if (value) {
                      emailVerificationChecker();
                    } else {
                      setState(() {
                        progress1 = false;
                      });
                    }
                  });
                },
              )),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 3,
          ),
          //SIGN UP Button
          Visibility(
            visible: !progress1,
            child: InkWell(
              onTap: () {
                setState(() {
                  progress1 = true;
                });
                Auth()
                    .createUserWithEmail(
                        tECEMail.text, tECPassword.text, context)
                    .then((value) {
                  if (value) {
                    // if returns true, that means verification has been sent
                    emailVerificationChecker();
                  } else {
                    setState(() {
                      progress1 = false;
                    });
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [color2, color3],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Container(
                  decoration: const BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 19, vertical: 11),
                  child: Text(
                    "SIGN UP",
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(color: color4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void emailVerificationChecker() {
    box.put("infoRestaurant", {});
    Auth().checkEMailVerification().then((value) {
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("E-Mail Verification has been sent!")));
      } else {
        goToPersonalManagerPage();
      }
    });
  }

  void goToPersonalManagerPage() {
    box.put("password", tECPassword.text);
    box.put("restaurant", false);
    Funcs().navigatorPushReplacement(context, const PersonelManagerPage());
  }
}
