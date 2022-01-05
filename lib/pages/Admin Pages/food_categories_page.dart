import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/restaurant.dart';

import '../../UIs/custom_gradient_button.dart';
import '../../UIs/custom_textfield.dart';
import '../../colors.dart';
import '../../firebase/Firestore.dart';
import '../../size.dart';

class FoodCategoriesPage extends StatefulWidget {
  const FoodCategoriesPage({Key? key, required this.restaurant})
      : super(key: key);
  final Restaurant restaurant;

  @override
  _FoodCategoriesPageState createState() => _FoodCategoriesPageState();
}

class _FoodCategoriesPageState extends State<FoodCategoriesPage>
    with AutomaticKeepAliveClientMixin<FoodCategoriesPage> {
  TextEditingController tECName = TextEditingController();

  bool progress1 = false;
  bool progress2 = false;
  bool progress3 = false;

  ///* [progress4] if there's a change it will be true
  bool progress4 = false;
  bool progress5 = false;

  int pickedEdit = -1;

  Map category = {};
  List categories = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    category.isEmpty
                        ? "Last Updated Date: Unknown.."
                        : "Last Updated Date: " +
                            Funcs().formatDateTime(
                                DateTime.parse(category['updateDate'])),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: color4, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: SizeConfig().setHight(2),
                ),
                CustomTextField(
                  text: "Category Name*",
                  textEditingController: tECName,
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
                              tECName.clear();
                              pickedEdit = -1;
                              setState(() {
                                progress5 = false;
                              });
                            },
                          ),
                          CustomGradientButton(
                            context: context,
                            text: "Edit",
                            func: () {
                              if (categories[pickedEdit] == tECName.text) {
                                Funcs().showSnackBar(context, "Not same name");
                              } else {
                                editCategoryName(pickedEdit);
                                tECName.clear();
                                pickedEdit = -1;
                                setState(() {
                                  progress5 = false;
                                });
                              }
                            },
                          ),
                        ],
                      )
                    : Visibility(
                        visible: !progress3,
                        child: CustomGradientButton(
                          context: context,
                          text: "Add",
                          func: () => checkCategoryName(),
                        ),
                      ),
                SizedBox(
                  height: SizeConfig().setHight(3),
                ),
                categories.isEmpty
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
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (_, index) {
                          return widgetShowData(index);
                        },
                      ),
                SizedBox(
                  height: SizeConfig().setHight(3),
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
                  height: SizeConfig().setHight(6),
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
            text: "GET CATEGORIES",
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
                      context: context, isFoodMenu: false)
                  .then((value) {
                if (value != null) {
                  if (value.isNotEmpty) {
                    category = value;
                    categories = category['data'];
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
                categories[index],
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
                  tECName.text = categories[pickedEdit];
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

  //FUNCTIONSSSSSSSSSSSSSSSS

  Future<void> uploadChanges() async {
    Navigator.pop(context);
    FocusScope.of(context).unfocus();
    setState(() {
      progress3 = true;
    });
    if (progress4) {
      await Firestore.setFoodMenuOrCategory(
              context: context, isFoodMenu: false, list: categories)
          .then((value) {
        if (value) {
          progress4 = false;
        }
      });
    } else {
      Funcs().showSnackBar(context, "Nothing has changed!");
    }
    setState(() {
      progress3 = false;
    });
  }

  void deleteCategory(int index) {
    progress4 = true;
    setState(() {
      categories.removeAt(index);
    });
  }

  void editCategoryName(int index) {
    FocusScope.of(context).unfocus();

    if (tECName.text.isEmpty) {
      Funcs().showSnackBar(context, "Category Name can not be empty!");
      return;
    }

    for (String value in categories) {
      if (value.toLowerCase().trim().replaceAll(" ", "") ==
          tECName.text.trim().toLowerCase().replaceAll(" ", "")) {
        Funcs().showSnackBar(context, "This category already exists!");
      } else {
        categories[index] = tECName.text.trim();
        progress4 = true;
        Funcs().showSnackBar(context, "Done!");
      }
    }

    tECName.clear();
  }

  void checkCategoryName() {
    FocusScope.of(context).unfocus();

    if (tECName.text.isEmpty) {
      Funcs().showSnackBar(context, "Category Name can not be empty!");
    } else {
      for (String value in categories) {
        if (value.toLowerCase().trim().replaceAll(" ", "") ==
            tECName.text.trim().toLowerCase().replaceAll(" ", "")) {
          Funcs().showSnackBar(context, "This category already exists!");
          tECName.clear();
          return;
        }
      }

      progress4 = true;
      categories.insert(0, tECName.text.trim());
      Funcs().showSnackBar(context, "Added!");

      tECName.clear();
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}
