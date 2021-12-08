import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Database.dart';
import 'package:restaurant_app/models/food.dart';

import 'package:restaurant_app/models/order.dart';

class ChefPage extends StatefulWidget {
  const ChefPage({
    Key? key,
  }) : super(key: key);

  @override
  _ChefPageState createState() => _ChefPageState();
}

class _ChefPageState extends State<ChefPage> {
  List<SliverList> innerLists = [];
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => listeners());
  }

  listeners() {
    FirebaseDatabase(
            databaseURL:
                "https://restaurant-app-99f29-default-rtdb.europe-west1.firebasedatabase.app")
        .reference()
        .child("orders")
        .onChildAdded
        .listen((event) {
      orders.add(Order.fromJson(event.snapshot.value));
      loadWidgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarForPersons(
        text: "Chef",
      ),
      body: CustomScrollView(slivers: innerLists),
    );
  }

  //FUNCTİONS --------------

  void loadWidgets() {
    var numLists = orders.length ~/ 2;
    if (orders.length == 1) {
      numLists = 1;
    }
    var numberOfItemsPerList = orders.length;
    var counter = 0;
    for (int i = 0; i < numLists; i++) {
      final _innerList = <WidgetOrderTicket>[];
      for (int j = 0; j < numberOfItemsPerList; j++) {
        _innerList.add(WidgetOrderTicket(
          order: orders[counter],
          funcDone: () async {
            doneOrder(counter);
          },
        ));
        counter++;
      }
      innerLists.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _innerList[index],
            childCount: numberOfItemsPerList,
          ),
        ),
      );
    }
    setState(() {});
  }

  Future doneOrder(counter) async {
    bool boolean = await Database()
        .deleteOrder(context, orders[counter - 1].databaseReference!);
    if (boolean) {
      setState(() {
        orders.removeAt(counter - 1);
      });
    }
  }
}

@immutable
class WidgetOrderTicket extends StatefulWidget {
  const WidgetOrderTicket(
      {Key? key, required this.order, required this.funcDone})
      : super(key: key);
  final Order order;
  final Function() funcDone;

  @override
  State createState() => WidgetOrderTicketState();
}

class WidgetOrderTicketState extends State<WidgetOrderTicket> {
  bool ready = false;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: const ValueKey(3),
      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),
        children: [
          // A SlidableAction can have an icon and/or a label.
          SlidableAction(
            onPressed: (context) {
              setState(() {
                ready = !ready;
              });
            },
            backgroundColor: ready ? Colors.red : Colors.yellow[700]!,
            foregroundColor: Colors.white,
            icon: ready ? Icons.cancel : Icons.done,
            label: ready ? 'NOT READY' : 'READY',
          ),
        ],
      ),
      endActionPane: !ready
          ? null
          : ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  onPressed: (context) => widget.funcDone.call(),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.done_all_sharp,
                  label: 'DONE',
                ),
              ],
            ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: ready ? Colors.yellow[700]! : color4,
            borderRadius: BorderRadius.all(Radius.circular(6))),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID: ${widget.order.id}",
              style: Theme.of(context).textTheme.headline5,
            ),
            Divider(
              color: Colors.grey[850],
              thickness: 1,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.order.foods!.length,
              itemBuilder: (_, index) {
                var food = Food.fromJson(widget.order.foods![index]);
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
    // ChildOrderTicket(
    //   price: widget.order.price!,
    //   foods: List<Food>.generate(widget.order.foods!.length,
    //       (index) => Food.fromJson(widget.order.foods![index])),
    //   inkWellOnTap: (index) {},
    //   shrinkWrap: true,
    // );
  }
}
