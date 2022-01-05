import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/UIs/widget_order_ticket.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/order.dart';

class PreOrdersPage extends StatefulWidget {
  const PreOrdersPage({Key? key}) : super(key: key);

  @override
  _PreOrdersPageState createState() => _PreOrdersPageState();
}

class _PreOrdersPageState extends State<PreOrdersPage> {
  List preOrders = Lists().box.get("paymentsWithError") ?? [] as List<Order>;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarForPersons(
        text: "Pre Orders",
        isPushed: true,
      ),
      body: body(),
    );
  }

  body() {
    return Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: preOrders.length,
          itemBuilder: (context, index) {
            return WidgetOrderTicket(
              order: preOrders[index],
              isCashier: true,
              pay: () {
                putOrder(index);
              },
            );
          },
        ),
      ],
    );
  }

  Future putOrder(int index) async {
    SimpleUIs().showProgressIndicator(context);
    bool isDone =
        await Firestore.payOrder(context: context, order: preOrders[index]);
    if (isDone) {
      preOrders.removeAt(index);
      Lists().box.put("paymentsWithError", preOrders);
    }
    Navigator.pop(context);
    setState(() {
      
    });
  }
}
