import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/size.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({Key? key, required this.pickedFoods}) : super(key: key);

  final List<Food> pickedFoods;

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  List foods = Lists.foods?['data']??[];

  List<String> categories = ["-Categories-", "All"];

  List<Food> pickedFoods = [];

  int pickedCategory = 1;

  bool progress1 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var food in foods) {
      if (categories.contains(food.category) == false) {
        categories.add(food.category);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        askToExit();
        return false;
      },
      child: Scaffold(
        appBar: AppbarForPersons(
          isPushed: true,
          text: "Foods",
          functionForLeadingIcon: () {
            askToExit();
          },
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  progress1 = !progress1;
                });
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: Icon(
                progress1
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            // Note: Sensitivity is integer used when you don't want to mess up vertical drag
            int sensitivity = 8;
            if (details.localPosition.dx < 100.0 &&
                details.delta.dx > sensitivity) {
              askToExit();
            }
          },
          child: body(),
        ),
      ),
    );
  }

  body() {
    //progress1 is true, that means Pickef Foods will be shown
    if (progress1) {
      return widgetPickedFoods();
    } else {
      return widgetPickFood();
    }
  }

  Padding widgetPickedFoods() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            "Picked Foods",
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Colors.grey[850],
            thickness: 1,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: pickedFoods.length,
            itemBuilder: (_, index) {
              return widgetContainerFood(pickedFoods[index].name, index, true);
            },
          ))
        ],
      ),
    );
  }

  Padding widgetPickFood() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              int picked = await SimpleUIs()
                  .showGeneralDialogFunc(context, categories, pickedCategory);
              if (picked != 0) {
                setState(() {
                  pickedCategory = picked;
                });
              }
            },
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Category: " + categories[pickedCategory],
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: color4, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey[850],
            thickness: 1,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foods.length,
              itemBuilder: (_, index) {
                if (!widget.pickedFoods.contains(foods[index]) &&
                        categories[pickedCategory] == categories[1] ||
                    categories[pickedCategory] == foods[index].category) {
                  return widgetContainerFood(foods[index].name, index, false);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget widgetContainerFood(String text, int index, bool isPickedFoods) {
    return InkWell(
      onLongPress: () {
        if (isPickedFoods) {
          pickedFoods.removeWhere((element) => element == pickedFoods[index]);
        } else {
          if (pickedFoods.contains(foods[index])) {
            pickedFoods.removeWhere((element) => element == foods[index]);
          } else {
            pickedFoods.add(foods[index]);
          }
        }

        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        width: double.infinity,
        decoration: BoxDecoration(
            color: color4,
            border: Border.all(
                color: isPickedFoods || pickedFoods.contains(foods[index])
                    ? Colors.blueAccent
                    : color4,
                width: SizeConfig().setWidth(1)),
            borderRadius: const BorderRadius.all(Radius.circular(6))),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /////////////////FUNCTİON

  askToExit() {
    SimpleUIs.showCustomDialog(
      context: context,
      title: "QUIT",
      actions: [
        CustomGradientButton(
          context: context,
          text: "WITHOUT",
          isOutlined: true,
          color: color1,
          func: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        CustomGradientButton(
          context: context,
          text: "WITH",
          func: () {
            Navigator.pop(context);
            Navigator.pop(context, pickedFoods);
          },
        ),
      ],
      content: Text(
        "Do you want to quit with picked foods or without?",
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: color4, fontWeight: FontWeight.bold),
      ),
    );
  }
}
