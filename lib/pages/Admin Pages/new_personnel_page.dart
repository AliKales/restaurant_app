import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/personnel_ui.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/pages/Admin%20Pages/add_new_personal.dart';
import 'package:restaurant_app/pages/Admin%20Pages/remove_update_page.dart';
import 'package:restaurant_app/size.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NewPersonnelPage extends StatefulWidget {
  const NewPersonnelPage(
      {Key? key,
      required this.restaurant,
      required this.logedIn,
      required this.goToPayment})
      : super(key: key);
  final Restaurant restaurant;
  final Function() logedIn;
  final Function() goToPayment;

  @override
  _NewPersonnelPageState createState() => _NewPersonnelPageState();
}

class _NewPersonnelPageState extends State<NewPersonnelPage>
    with AutomaticKeepAliveClientMixin<NewPersonnelPage> {
  bool isLoggedIn = false;
  bool progress1 = false;
  //progress2 is for when personnels getting from database
  bool progress2 = false;
  //progress3 is for button 'load more'
  bool? progress3 = false;
  bool progress4 = false;
  bool progress5 = false;
  bool isPasswordShown = true;

  int? daysLeft;

  TextEditingController tECPassword = TextEditingController();

  List<Personnel> personnels = [];

  @override
  void initState() {
    calculateDays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoggedIn) {
      //when admin has logged in
      return Align(
        alignment: Alignment.topCenter,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  widget.restaurant.restaurantName,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: color4, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical! * 3,
                ),
                //button new personnel
                progress5
                    ? CustomGradientButton(
                        context: context,
                        text: "TRY AGAIN",
                        color: color1,
                        isOutlined: true,
                        func: () {
                          setState(() {
                            progress5 = false;
                          });
                          calculateDays();
                        },
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            daysLeft == null
                                ? "Loading.."
                                : "$daysLeft Days Left",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: color4),
                          ),
                          TextButton(
                              onPressed: () {
                                if (daysLeft! <= 30) {
                                  widget.goToPayment.call();
                                } else {
                                  Funcs().showSnackBar(context,
                                      "For now you can purchase maximum 60 days!");
                                }
                              },
                              child: Text(
                                "Pay",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(color: color2),
                              ))
                        ],
                      ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical! * 5,
                ),
                Visibility(
                  visible: !progress2,
                  child: CustomGradientButton(
                    context: context,
                    text: "New Personnel",
                    func: () async {
                      Personnel personnel = await Funcs().navigatorPush(
                          context,
                          AddNewPersonal(
                            restaurantName: widget.restaurant.restaurantName,
                          ));
                      personnels.insert(0, personnel);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.person_add_alt_rounded,
                      color: color4,
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig().setHight(3),
                ),
                //sort
                Visibility(visible: !progress2, child: widgetSort()),
                //list view builder for personnels
                SimpleUIs()
                    .widgetWithProgress(widgetListForPersonnels(), progress2),
                !progress4
                    ? const SizedBox.shrink()
                    : CustomGradientButton(
                        loading: progress3,
                        context: context,
                        isOutlined: true,
                        color: color1,
                        text: "Load More",
                        func: () async {
                          setState(() {
                            progress3 = true;
                          });
                          String lastId = personnels[personnels.length - 1].id;
                          personnels = await Firestore.getPersonnels(
                              lastPersonnelId:
                                  personnels[personnels.length - 1].id,
                              context: context,
                              list: personnels);
                          if (personnels[personnels.length - 1].id == lastId) {
                            progress4 = false;
                          }
                          setState(() {
                            progress3 = false;
                          });
                        },
                      ),
                SizedBox(
                  height: SizeConfig().setHight(3),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // When admin is not logged in
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: kIsWeb
            ? SingleChildScrollView(
                child: widgetChild(context),
              )
            : widgetChild(context),
      );
    }
  }

  Column widgetChild(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 20,
        ),
        //Admin password
        CustomTextField(
          textEditingController: tECPassword,
          text: "Admin Password",
          iconData: Icons.lock_outline,
          obscureText: isPasswordShown,
          suffixIconFunction: () {
            setState(() {
              isPasswordShown = !isPasswordShown;
            });
          },
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 6,
        ),
        // Log in
        CustomGradientButton(
          context: context,
          text: "LOG IN",
          loading: progress1,
          func: () {
            FocusScope.of(context).unfocus();
            setState(() {
              progress1 = true;
            });
            if (tECPassword.text == widget.restaurant.password) {
              isLoggedIn = true;
              widget.logedIn.call();
              setState(() {
                progress2 = true;
                personnelsCheckFromDB();
              });
              Funcs().showSnackBar(context, "Logged In!");
            } else if (tECPassword.text.isEmpty) {
              Funcs().showSnackBar(context, "Password can't be empty!");
            } else {
              Funcs().showSnackBar(context, "Wrong password!");
            }
            setState(() {
              progress1 = false;
            });
          },
        )
      ],
    );
  }

  dynamic widgetSort() {
    return Visibility(
      visible: personnels.isNotEmpty,
      child: Align(
        alignment: Alignment.centerRight,
        child: PopupMenuButton(
          elevation: 10,
          color: color1,
          icon: const Icon(
            Icons.sort_rounded,
            color: color4,
          ),
          itemBuilder: (BuildContext context) => List.generate(
            Lists().roles.length-1,
            (index) {
              index++;
              return PopupMenuItem(
              child: Text(
                Lists().roles[index],
                style: const TextStyle(color: color4, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                personnels =
                    Funcs().sortList(Lists().roles[index], "role", personnels);
                setState(() {});
              },
            );
            },
          ),
        ),
      ),
    );
  }

  dynamic widgetListForPersonnels() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: personnels.length,
      itemBuilder: (_, index) {
        return PersonnelUI(
          personnel: personnels[index],
          dotsClicked: () async {
            var value = await Funcs().navigatorPush(
              context,
              RemoveUpdatePage(
                personnel: personnels[index],
              ),
            );
            if (value != null && value['what'] == 'delete') {
              setState(() {
                personnels.removeAt(index);
              });
              //here it checks if listview is empty, if it is then it shows loading proccess and get new personnels from databa
              //if there is no more personnels then it close everything
              if (personnels.isEmpty) {
                setState(() {
                  progress2 = true;
                  progress4 = false;
                });
                await personnelsCheckFromDB().then((value) {
                  if (value) {
                    progress4 = true;
                  }
                });
                setState(() {
                  progress2 = false;
                });
              }
            } else if (value != null && value['what'] == 'update') {
              personnels[personnels.indexWhere(
                      (element) => element.id == value['personnel'].id)] =
                  value['personnel'];
              setState(() {});
            }
          },
        );
      },
    );
  }

  //FUNCTIONSSSSSSSSSSSSS
  Future calculateDays() async {
    await Funcs()
        .getCurrentGlobalTimeForRestaurantCreating(context)
        .then((value) {
      if (value == null) {
        progress5 = true;
      } else {
        daysLeft = DateTime.parse(widget.restaurant.paymentDate)
            .difference(value)
            .inDays;
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future personnelsCheckFromDB() async {
    String id = "";
    if (personnels.isNotEmpty) {
      id = personnels[personnels.length - 1].id;
    }

    personnels = await Firestore.getPersonnels(
        lastPersonnelId: id, context: context, list: personnels);
    if (personnels.isNotEmpty) {
      progress4 = true;
    }
    setState(() {
      progress2 = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
