import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/UIs/note_page_widget.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/models/food.dart';

import '../colors.dart';
import '../funcs.dart';
import '../size.dart';
import 'custom_gradient_button.dart';
import 'custom_textfield.dart';

class OrderTicket extends StatefulWidget {
  const OrderTicket(
      {Key? key,
      required this.price,
      this.isTextFieldActive = true,
      required this.foods,
      this.progress2,
      this.noTouch = false,
      this.absoring = false,
      this.isNoSlide = false,
      this.tECID,
      this.add,
      required this.inkWellOnTap,
      this.funcDelete,
      this.funcOrder,
      this.buttonText = "ADD",
      this.funcNote})
      : super(key: key);

  final double price;
  final bool isTextFieldActive;
  final List<Food> foods;
  final bool? progress2;
  final bool noTouch;
  final bool absoring;
  final bool isNoSlide;
  final TextEditingController? tECID;
  final Function()? add;
  final Function(int index)? inkWellOnTap;
  final Function()? funcDelete;
  final Function()? funcOrder;
  final Function(String)? funcNote;

  ///* [buttonText] is for either 'ADD' or 'UPDATE' the ticket
  final String buttonText;

  static var formatCurrency = NumberFormat.simpleCurrency();

  @override
  State<OrderTicket> createState() => _OrderTicketState();
}

class _OrderTicketState extends State<OrderTicket> {
  bool isNoteOpen = false;
  String note = "";
  @override
  Widget build(BuildContext context) {
    if (isNoteOpen) {
      return Expanded(
        child: NotePageWidget(
          note: note,
          closeButton: (value) {
            widget.funcNote?.call(value) ?? () {};
            note = value;
            setState(() {
              isNoteOpen = false;
            });
          },
        ),
      );
    }
    return body();
  }

  Expanded body() {
    return Expanded(
      child: AbsorbPointer(
        absorbing: widget.absoring,
        child: Slidable(
          key: const ValueKey(0),
          // The start action pane is the one at the left or the top side.
          startActionPane: widget.isNoSlide
              ? null
              : ActionPane(
                  // A motion is a widget used to control how the pane animates.
                  motion: const ScrollMotion(),
                  children: [
                    // A SlidableAction can have an icon and/or a label.
                    SlidableAction(
                      onPressed: (context) => widget.funcDelete?.call() ?? {},
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: widget.isNoSlide
              ? null
              : ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      onPressed: (context) => widget.funcOrder?.call() ?? {},
                      backgroundColor: Color(0xFF7BC043),
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'Order',
                    ),
                  ],
                ),
          child: ChildOrderTicket(
            noTouch: widget.noTouch,
            progress2: widget.progress2,
            foods: widget.foods,
            inkWellOnTap: widget.inkWellOnTap,
            price: widget.price,
            add: widget.add,
            tECID: widget.tECID,
            buttonText: widget.buttonText,
            longPress: () {
              setState(() {
                isNoteOpen = true;
              });
            },
            isTextFieldActive: widget.isTextFieldActive,
          ),
        ),
      ),
    );
  }
}

class ChildOrderTicket extends StatelessWidget {
  const ChildOrderTicket(
      {Key? key,
      required this.price,
      this.isTextFieldActive = true,
      required this.foods,
      this.progress2,
      this.noTouch = false,
      this.tECID,
      this.add,
      required this.inkWellOnTap,
      this.shrinkWrap = false,
      this.buttonText = "ADD",
      this.id = "",
      this.longPress})
      : super(key: key);

  final double price;
  final bool isTextFieldActive;
  final List<Food> foods;
  final bool? progress2;
  final bool noTouch;
  final TextEditingController? tECID;
  final Function()? add;
  final Function(int index)? inkWellOnTap;
  final Function()? longPress;
  final bool shrinkWrap;
  final String buttonText;
  final String id;

  @override
  Widget build(BuildContext context) {
    if (id != "" && tECID != null) tECID?.text = id;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onLongPress: () => longPress?.call() ?? {},
            child: Container(
              width: double.infinity,
              color: color4,
              child: Column(
                children: [
                  Text(
                    "ORDER",
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: color1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Divider(
                      color: Colors.grey[850],
                      thickness: 1,
                    ),
                  ),
                  Visibility(
                    visible: noTouch == false,
                    child: CustomGradientButton(
                      context: context,
                      loading: progress2,
                      text: buttonText,
                      func: add ?? () {},
                    ),
                  ),
                  isTextFieldActive == false
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            textEditingController: tECID,
                            isFilled: true,
                            readOnly: noTouch,
                            filledColor: Colors.grey[350],
                            text: "Id or Name:",
                            colorHint: Colors.black,
                            textStyle: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: Colors.black),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: Colors.grey[850],
                      thickness: 1,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        shrinkWrap: shrinkWrap,
                        itemCount: foods.length,
                        itemBuilder: (_, index) {
                          return InkWell(
                            onTap: () => inkWellOnTap!(index),
                            onLongPress: () {
                              if (foods[index].info!.isEmpty) {
                                Funcs().showSnackBar(context, "No info!");
                              } else {
                                SimpleUIs.showCustomDialog(
                                    context: context,
                                    actions: [
                                      CustomGradientButton(
                                        context: context,
                                        text: "OK",
                                        func: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                    barriedDismissible: true,
                                    title: foods[index].name,
                                    content: Text(
                                      foods[index].info!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(color: color4),
                                    ));
                              }
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  height: SizeConfig().setHight(1),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      foods[index].count.toString() + " - ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: color1,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      foods[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: color1,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      OrderTicket.formatCurrency.format(
                                          double.parse(foods[index].price) *
                                              foods[index].count),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: color1,
                                              fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig().setHight(1),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: Divider(
                                    color: Colors.grey[850],
                                    thickness: 1,
                                  ),
                                ),
                                Visibility(
                                  visible: index == foods.length - 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Total= " +
                                          NumberFormat.simpleCurrency()
                                              .format(price),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: color1,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: SizeConfig().setWidth(7),
            width: SizeConfig().setWidth(7),
            decoration:
                const BoxDecoration(color: color1, shape: BoxShape.circle),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            height: SizeConfig().setWidth(7),
            width: SizeConfig().setWidth(7),
            decoration:
                const BoxDecoration(color: color1, shape: BoxShape.circle),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            height: SizeConfig().setWidth(7),
            width: SizeConfig().setWidth(7),
            decoration:
                const BoxDecoration(color: color1, shape: BoxShape.circle),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: SizeConfig().setWidth(7),
            width: SizeConfig().setWidth(7),
            decoration:
                const BoxDecoration(color: color1, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}
