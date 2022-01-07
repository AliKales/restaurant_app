import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Auth.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/order_status.dart';

@immutable
class WidgetOrderTicket extends StatefulWidget {
  const WidgetOrderTicket(
      {Key? key,
      required this.order,
      this.funcDone,
      this.longPress,
      this.isCashier = false,
      this.pay,
      this.isBorder = false,
      this.doubleTap,
      this.isChef = true,
      this.delete})
      : super(key: key);
  final Order order;
  final Function()? funcDone;
  final Function(String?)? longPress;
  final Function()? doubleTap;
  final Function()? pay;
  final Function()? delete;
  final bool isCashier;
  final bool isBorder;
  final bool isChef;

  @override
  State createState() => WidgetOrderTicketState();
}

class WidgetOrderTicketState extends State<WidgetOrderTicket> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCashier) {
      return Slidable(
          key: const ValueKey(6),
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: (context) {
                  widget.pay?.call() ?? () {};
                },
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.done,
                label: "PAY",
              ),
            ],
          ),
          endActionPane: widget.delete == null
              ? null
              : ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      onPressed: (context) {
                        widget.delete?.call() ?? () {};
                      },
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'DELETE',
                    ),
                  ],
                ),
          child: widgetChild(context));
    } else {
      return widgetSlidableNotCashier(context);
    }
  }

  Slidable widgetSlidableNotCashier(BuildContext context) {
    return Slidable(
      key: const ValueKey(3),
      // The start action pane is the one at the left or the top side.
      startActionPane: (widget.order.status == OrderStatus.updating ||
              !widget.isChef)
          ? null
          : ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const ScrollMotion(),
              children: [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                  onPressed: (context) async {
                    if (widget.order.status == OrderStatus.waiting) {
                      update();
                    } else {
                      await Database.updateOrder(
                          context: context,
                          databaseReference: widget.order.databaseReference!,
                          update: {
                            'status': Order.enumToString(OrderStatus.waiting)
                          });
                    }
                  },
                  backgroundColor: widget.order.status == OrderStatus.waiting
                      ? Colors.yellow[700]!
                      : Colors.red,
                  foregroundColor: Colors.white,
                  icon: widget.order.status == OrderStatus.waiting
                      ? Icons.done
                      : Icons.cancel,
                  label: widget.order.status == OrderStatus.waiting
                      ? "COOKING"
                      : "NO COOK",
                ),
              ],
            ),
      endActionPane: widget.order.status == OrderStatus.cooking
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  onPressed: (context) {
                    widget.funcDone?.call() ?? () {};
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.done_all_sharp,
                  label: 'READY',
                ),
              ],
            )
          : null,
      child: widgetChild(context),
    );
  }

  InkWell widgetChild(BuildContext context) {
    return InkWell(
      onDoubleTap: () {
        widget.doubleTap?.call();
      },
      onLongPress: () {
        if (widget.order.note != "") {
          widget.longPress?.call(widget.order.note) ?? () {};
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border:
                !widget.isBorder ? null : Border.all(color: color2, width: 8),
            color: backgroundColor(),
            borderRadius: BorderRadius.all(Radius.circular(6))),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
                visible: widget.order.note != "",
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                )),
            Text(
              "ID: ${widget.order.id}",
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              "Price: ${Funcs().formatMoney(widget.order.price)}",
              style: Theme.of(context).textTheme.headline5,
            ),
            Divider(
              color: Colors.grey[850],
              thickness: 1,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.order.foods.length,
              itemBuilder: (_, index) {
                var food = Food.fromJson(widget.order.foods[index]);
                return Row(
                  children: [
                    Text(
                      food.name,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      " x${food.count}",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color backgroundColor() {
    switch (widget.order.status) {
      case OrderStatus.cooking:
        return Colors.yellow[700]!;
      case OrderStatus.waiting:
        return color4;
      case OrderStatus.updating:
        return Colors.lightBlue;

      default:
        return color4;
    }
  }

  //FUNCTIONSSSSSSSSSSSSSSSSSSSSSS

  Future update() async {
    try {
      FirebaseDatabase(
              databaseURL:
                  "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
          .reference()
          .child("orders")
          .child(Auth().getUID())
          .child(widget.order.databaseReference!)
          .runTransaction((mutableData) {
        if (mutableData.value == null) {
          Navigator.pop(context);
          Funcs().showSnackBar(context, "ERROR! PLEASE TRY AGAIN");
          return mutableData;
        }
        SimpleUIs().showProgressIndicator(context);
        if (Order.fromJson(mutableData.value).status == OrderStatus.updating) {
          Database.updateOrder(
                  context: context,
                  databaseReference: widget.order.databaseReference!,
                  update: {'status': Order.enumToString(OrderStatus.updating)})
              .then((value) {
            Navigator.pop(context);
          });
          Funcs().showSnackBar(context, "This order is getting Updated..");
        } else if (Order.fromJson(mutableData.value).status !=
            OrderStatus.ready) {
          Database.updateOrder(
                  context: context,
                  databaseReference: widget.order.databaseReference!,
                  update: {'status': Order.enumToString(OrderStatus.cooking)})
              .then((value) {
            Navigator.pop(context);
          });
        } else {
          Navigator.pop(context);
        }

        return mutableData;
      });
    } on FirebaseException {
      Navigator.pop(context);
      Funcs().showSnackBar(context, "ERROR!");
    } catch (e) {
      Navigator.pop(context);
      Funcs().showSnackBar(context, "ERROR!");
    }
  }
}
