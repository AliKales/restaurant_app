import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/UIs/widget_order_ticket.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/restaurant.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _AllOrdersPageState createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  List<Order>? orders;

  bool progress1 = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SimpleUIs.emptyWidget(height: 1),
          Text(
            orders == null
                ? "Last Update: ---"
                : "Last Update: ${DateTime.now().toString().split(".")[0].substring(0, 16)}",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: color4, fontWeight: FontWeight.bold),
          ),
          SimpleUIs.emptyWidget(height: 2),
          Visibility(
            visible: orders == null,
            child: SimpleUIs().widgetWithProgress(
              CustomGradientButton(
                context: context,
                text: "LOAD",
                func: () {
                  loadOrders();
                },
              ),
              progress1,
            ),
          ),
          ListView.builder(
            itemCount: orders?.length ?? 0,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return WidgetOrderTicket(
                order: orders![index],
                isCashier: true,
                pay: () {
                  payOrder(orders![index]);
                },
                delete: () {
                  deleteOrder(orders![index].databaseReference!);
                },
                longPress: (note) {
                  SimpleUIs.showCustomDialog(
                      context: context,
                      title: "NOTE:",
                      content: Text(
                        note ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: color4),
                      ));
                },
              );
            },
          )
        ],
      ),
    );
  }

  //FUNCTİONSSSSSSSSS
  Future payOrder(Order orderValue) async {
    SimpleUIs().showProgressIndicator(context);

    bool? isPaid = await Database.deleteOrder(
        context: context,
        databaseReference: orderValue.databaseReference!,
        isPaying: true);

    if (isPaid == null) {
      Navigator.pop(context);
      return;
    }

    if (isPaid) {
      bool isPaid2 =
          await Firestore.payOrder(context: context, order: orderValue);
      if (!isPaid2) {
        List list = Lists().box.get("paymentsWithError");
        list.add(orderValue);
        Lists().box.put("paymentsWithError", list);
      }

      orders!.removeWhere((element) =>
          element.databaseReference == orderValue.databaseReference);

      setState(() {});
    }

    Navigator.pop(context);
    setState(() {});
  }

  Future deleteOrder(String databaseReference) async {
    SimpleUIs().showProgressIndicator(context);
    bool? response = await Database.deleteOrder(
        context: context, databaseReference: databaseReference);
    if (response != null && response == true) {
      orders!.removeWhere(
          (element) => element.databaseReference == databaseReference);
    }
    Navigator.pop(context);
    setState(() {});
  }

  Future loadOrders() async {
    setState(() {
      progress1 = true;
    });
    orders = await Database.getAllOrders(context: context);
    setState(() {
      progress1 = false;
    });
  }
}
