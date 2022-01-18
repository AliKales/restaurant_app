import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/restaurant.dart';

import '../../colors.dart';
import '../../size.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  bool progress1 = false;
  bool progress2 = false;
  bool progress3 = false;
  bool progress4 = false;
  bool progress5 = false;

  Map foodMenu = {};

  List foods = [];
  List categories = [];

  int pickedCategory = -1;
  int pickedEdit = -1;

  TextEditingController tECName = TextEditingController();
  TextEditingController tECInfo = TextEditingController();
  TextEditingController tECPrice = TextEditingController();
  TextEditingController tECCategory = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //this mean when its true then it return the Food menu otherwise it returns button get Food Menu from database
    if (progress1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                widgetTextRestaurantName(context),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    foodMenu.isEmpty
                        ? "Last Updated Date: Unknown.."
                        : "Last Updated Date: " +
                            Funcs().formatDateTime(
                                DateTime.parse(foodMenu['updateDate'])),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: color4, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: SizeConfig().setHight(1),
                ),
                CustomGradientButton(
                  context: context,
                  text: "Upload",
                  loading: progress3,
                  func: () {
                    SimpleUIs.showCustomDialog(
                        context: context,
                        title: "WARNING!",
                        content: Text(
                          "Please be sure that you are all done with your changes to update. We would like you to update all of your changes at the same time.",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: color4),
                        ),
                        actions: [
                          CustomGradientButton(
                            context: context,
                            color: color1,
                            isOutlined: true,
                            text: "Cancel",
                            func: () {
                              Navigator.pop(context);
                            },
                          ),
                          CustomGradientButton(
                            context: context,
                            text: "Upload",
                            func: () => uploadChanges(),
                          )
                        ]);
                  },
                ),
                SizedBox(
                  height: SizeConfig().setHight(1),
                ),
                CustomTextField(
                  text: "Name*",
                  textEditingController: tECName,
                ),
                CustomTextField(
                  text: "Info",
                  textEditingController: tECInfo,
                ),
                CustomTextField(
                  text: "Price (\$20.36)*",
                  textEditingController: tECPrice,
                  prefixText: "\$",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                  ],
                ),
                CustomTextField(
                  function: () async {
                    int value = await SimpleUIs().showGeneralDialogFunc(
                        context, categories, pickedCategory);
                    if (value != -1) {
                      setState(() {
                        pickedCategory = value;
                        tECCategory.text = categories[pickedCategory];
                      });
                    }
                  },
                  text: "Category*",
                  readOnly: true,
                  textEditingController: tECCategory,
                ),
                SizedBox(
                  height: SizeConfig().setHight(3),
                ),
                progress5
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomGradientButton(
                            context: context,
                            text: "Cancel",
                            isOutlined: true,
                            color: color1,
                            func: () {
                              clearTECS();
                              pickedEdit = -1;
                              setState(() {
                                progress5 = false;
                              });
                            },
                          ),
                          CustomGradientButton(
                            context: context,
                            text: "Edit",
                            func: () async {
                              await editFood(pickedEdit);
                            },
                          ),
                        ],
                      )
                    : CustomGradientButton(
                        context: context,
                        text: "Add",
                        loading: progress3,
                        func: () {
                          checkText(false);
                        },
                      ),
                SizedBox(
                  height: SizeConfig().setHight(3),
                ),
                foods.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "No Data",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: color4, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foods.length,
                        itemBuilder: (_, index) {
                          return widgetShowData(index);
                        },
                      ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          widgetTextRestaurantName(context),
          CustomGradientButton(
            context: context,
            text: "GET FOOD MENU",
            icon: const Icon(
              Icons.fastfood_outlined,
              color: color4,
            ),
            loading: progress2,
            func: () async {
              setState(() {
                progress2 = true;
              });
              await Firestore.getFoodMenuOrCategory(
                      context: context, isFoodMenu: true)
                  .then((value) {
                if (value != null) {
                  if (value.isNotEmpty) {
                    foodMenu = value;
                    foods = foodMenu['data'];
                  }
                }
              });
              await Firestore.getFoodMenuOrCategory(
                      isFoodMenu: false, context: context)
                  .then((value) {
                if (value != null) {
                  if (value.isNotEmpty) {
                    categories = value['data'];
                  }
                  progress1 = true;
                }
              });
              setState(() {
                progress2 = false;
              });
            },
          )
        ],
      );
    }
  }

  Widget widgetShowData(int index) {
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // All actions are defined in the children parameter.
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (context) {
              deleteCategory(index);
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        width: double.infinity,
        decoration: BoxDecoration(
            color: color4,
            border: Border.all(
                color: pickedEdit == index ? Colors.green : Colors.blueAccent,
                width: SizeConfig().setWidth(1)),
            borderRadius: const BorderRadius.all(Radius.circular(6))),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                foods[index].name +
                    " - " +
                    NumberFormat.simpleCurrency()
                        .format(double.parse(foods[index].price)) +
                    " - " +
                    foods[index].category,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Visibility(
              visible: !progress3,
              child: IconButton(
                onPressed: () {
                  pickedEdit = index;
                  tECName.text = foods[index].name;
                  tECInfo.text = foods[index].info ?? "";
                  tECPrice.text = foods[index].price;
                  tECCategory.text = foods[index].category;
                  setState(() {
                    progress5 = true;
                  });
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
            )
          ],
        ),
      ),
    );
  }

  Column widgetTextRestaurantName(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.restaurant.restaurantName,
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: color4, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 6,
        ),
      ],
    );
  }

  //FUNCTIONS-------------------------------------------------------

  Future<void> editFood(int index) async {
    await checkText(true).then((value) {
      if (value != false) {
        foods[index].name = tECName.text.trim();
        foods[index].searchName =
            tECName.text.toLowerCase().trim().replaceAll(" ", "");
        foods[index].info = tECInfo.text.trim();
        foods[index].price = tECPrice.text.trim();
        foods[index].category = tECCategory.text;
        progress4 = true;
        clearTECS();
        pickedEdit = -1;
        setState(() {
          progress5 = false;
        });
        setState(() {});
      }
    });
  }

  void deleteCategory(int index) {
    progress4 = true;
    setState(() {
      foods.removeAt(index);
    });
  }

  Future<void> uploadChanges() async {
    Navigator.pop(context);
    FocusScope.of(context).unfocus();
    setState(() {
      progress3 = true;
    });
    if (progress4) {
      List list = [];
      for (var item in foods) {
        list.add(item.toMap());
      }
      await Firestore.setFoodMenuOrCategory(
              context: context, isFoodMenu: true, list: list)
          .then((value) {
        if (value) {
          progress4 = false;
          clearTECS();
        }
      });
    } else {
      Funcs().showSnackBar(context, "Nothing has changed!");
    }
    setState(() {
      progress3 = false;
    });
  }

  Future<bool> checkText(bool isForEdit) async {
    FocusScope.of(context).unfocus();
    bool isAdd = true;
    if (tECName.text.isEmpty ||
        tECCategory.text.isEmpty ||
        tECPrice.text.isEmpty) {
      Funcs().showSnackBar(
          context, "'Name' & 'Price' & 'Category' can not be empty!");
      isAdd = false;
      return false;
    } else if (tECPrice.text.split(".").length != 1) {
      if (tECPrice.text.split(".").length > 2 ||
          tECPrice.text.split(".")[1].length > 2) {
        Funcs().showSnackBar(
            context, "Wrong 'Price' formatting! Example= (\$10.28)");
        isAdd = false;
        return false;
      }
    }

    if (isAdd) {
      bool boolen = true;
      for (var item in foods) {
        if (item.searchName ==
            tECName.text.toLowerCase().trim().replaceAll(" ", "")) {
          boolen = false;
        }
      }

      if (boolen) {
        if (isForEdit) {
          return true;
        } else {
          foods.insert(
              0,
              Food(
                  name: tECName.text.trim(),
                  price: tECPrice.text.trim(),
                  info: tECInfo.text.trim(),
                  count: 1,
                  category: tECCategory.text.trim(),
                  id: foods.length + 1,
                  searchName:
                      tECName.text.toLowerCase().trim().replaceAll(" ", "")));
          Funcs().showSnackBar(context, "Added");
          progress4 = true;
          clearTECS();
          return true;
        }
      } else if (pickedEdit == -1 || tECName.text != foods[pickedEdit].name) {
        Funcs()
            .showSnackBar(context, "There is already food with same 'NAME'!");
        return false;
      }
    }
    setState(() {});
    return true;
  }

  void clearTECS() {
    tECName.clear();
    tECCategory.clear();
    tECInfo.clear();
    tECPrice.clear();
  }
}
