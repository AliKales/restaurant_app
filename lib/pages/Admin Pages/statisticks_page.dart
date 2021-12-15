import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/food.dart';
import 'package:restaurant_app/models/order.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/size.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StatisticksPage extends StatefulWidget {
  const StatisticksPage({Key? key, required this.restaurant}) : super(key: key);
  final Restaurant restaurant;

  @override
  _StatisticksPageState createState() => _StatisticksPageState();
}

class _StatisticksPageState extends State<StatisticksPage> {
  List<List<dynamic>> orders = [];
  List<int> months = [];
  List<Map> chartDatas = [];
  List<Map> allFoods = [];
  List<_ChartData> charts = [];
  List<SalesData> salesDatas = [
    SalesData("Jan", 0),
    SalesData("Feb", 0),
    SalesData("Mar", 0),
    SalesData("Apr", 0),
    SalesData("May", 0),
    SalesData("Jun", 0),
    SalesData("Jul", 0),
    SalesData("Aug", 0),
    SalesData("Sep", 0),
    SalesData("Oct", 0),
    SalesData("Nov", 0),
    SalesData("Dec", 0),
  ];
  String month = "Months";
  String list2SelectedFood = "Foods";

  int list1Selected = 0;
  int list2Selected = 0;

  double maximum = 0;
  double interval = 10;

  var box = Hive.box("database");

  List<String> monthsString = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  final List<ChartData> chartData = [
    ChartData(
      'Jan',
      0,
      const Color(0xFF00a000),
    ),
    ChartData(
      'Feb',
      0,
      const Color(0xFF3a65a0),
    ),
    ChartData(
      'Mar',
      0,
      const Color(0xFFfad5a0),
    ),
    ChartData(
      'Apr',
      0,
      const Color(0xFF00afd8),
    ),
    ChartData(
      'May',
      0,
      const Color(0xFF332343),
    ),
    ChartData(
      'Jun',
      0,
      const Color(0xFF54454a),
    ),
    ChartData(
      'Jul',
      0,
      const Color(0xFF243526),
    ),
    ChartData(
      'Aug',
      0,
      const Color(0xFF435363),
    ),
    ChartData(
      'Sep',
      0,
      const Color(0xFF545f22),
    ),
    ChartData(
      'Oct',
      0,
      const Color(0xFF456654),
    ),
    ChartData(
      'Nov',
      0,
      const Color(0xFF741234),
    ),
    ChartData(
      'Dec',
      0,
      const Color(0xFFf64523),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: kIsWeb ? ScrollController() : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
              height: SizeConfig().setHight(3),
            ),
            widgetButtonUpdate(),
            SizedBox(
              height: SizeConfig().setHight(3),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: allFoods.length,
              itemBuilder: (context, index) {
                return Text(
                  allFoods[index]['name'] +
                      " " +
                      Funcs().formatMoney(allFoods[index]['price']) +
                      " - Count: " +
                      allFoods[index]['count'].toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: color4),
                );
              },
            ),
            const Divider(color: Colors.black,height: 1,),
            SizedBox(
              height: SizeConfig().setHight(3),
            ),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    widgetFilter(month + "  ", () async {
                      int value = await SimpleUIs().showGeneralDialogFunc(
                          context, months, list1Selected);
                      list1Selected = value;
                      list(value, months[value], setState);
                    }),
                    SfCartesianChart(
                      plotAreaBorderColor: color4,
                      primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(color: color4)),
                      primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: maximum,
                          interval: interval,
                          labelStyle: const TextStyle(color: color4)),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<_ChartData, String>>[
                        ColumnSeries<_ChartData, String>(
                          dataSource: charts,
                          xValueMapper: (_ChartData data, _) => data.x,
                          yValueMapper: (_ChartData data, _) => data.y,
                          name: 'Sold',
                          trackColor: color4,
                          gradient: const LinearGradient(
                              colors: [color2, color3],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
            const Divider(color: Colors.black,height: 1,),
            SizedBox(
              height: SizeConfig().setHight(5),
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  widgetFilter(list2SelectedFood + "  ", () async {
                    int value = await SimpleUIs().showGeneralDialogFunc(
                        context,
                        List.generate(allFoods.length,
                            (index) => allFoods[index]['name']),
                        list2Selected);

                    list2Selected = value;
                    list2SelectedFood = allFoods[value]['name'];
                    list2(value, setState);
                  }),
                  SfCartesianChart(
                    primaryYAxis:
                        NumericAxis(labelStyle: const TextStyle(color: color4)),
                    primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(color: color4),
                        labelPlacement: LabelPlacement.onTicks),
                    series: <ChartSeries>[
                      LineSeries<SalesData, String>(
                        dataSource: salesDatas,
                        xValueMapper: (SalesData sales, _) => sales.month.substring(0,3),
                        yValueMapper: (SalesData sales, _) => sales.sales,
                        color: color2,
                      )
                    ],
                  )
                ],
              );
            }),
            const Divider(color: Colors.black,height: 1,),
            SizedBox(
              height: SizeConfig().setHight(3),
            ),
            kIsWeb
                ? Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: chartData.length,
                          itemBuilder: (_, index) {
                            return noName1(index, context);
                          },
                        ),
                      ),
                      Expanded(child: widgetCircleChart(context)),
                    ],
                  )
                : Column(
                    children: [
                      widgetCircleChart(context),
                      widgetMonthsForMobile(),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  StatefulBuilder widgetCircleChart(BuildContext context) {
    return StatefulBuilder(
      builder: (_, StateSetter setState) {
        return Column(
          children: [
            Align(
              child: CustomGradientButton(
                context: context,
                isOutlined: true,
                color: color1,
                text: "List",
                func: () => list3(setState),
              ),
            ),
            chartData.any((element) => element.y > 0)
                ? SfCircularChart(
                    series: <CircularSeries>[
                      // Render pie chart
                      PieSeries<ChartData, String>(
                        dataSource: chartData,
                        pointColorMapper: (ChartData data, _) => data.color,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelMapper: (ChartData data, _) =>
                            (data.y.toInt()).toString(),
                        dataLabelSettings: const DataLabelSettings(
                          textStyle: TextStyle(color: color4),
                          isVisible: true,
                          showZeroValue: false,
                          showCumulativeValues: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  GridView widgetMonthsForMobile() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chartData.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (context, index) {
        return noName1(index, context);
      },
    );
  }

  Row noName1(int index, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: kIsWeb ? SizeConfig().setWidth(2) : SizeConfig().setWidth(5),
          width: kIsWeb ? SizeConfig().setWidth(2) : SizeConfig().setWidth(5),
          decoration: BoxDecoration(
            color: chartData[index].color,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          " " + chartData[index].x,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: color4),
        ),
      ],
    );
  }

  CustomGradientButton widgetButtonUpdate() {
    return CustomGradientButton(
      context: context,
      text: "Update",
      func: () async {
        chartDatas = [];
        charts = [];
        maximum = 0;
        orders = [];
        months = [];
        salesDatas = [];
        allFoods = [];
        int selected = -1;

        List _list = List<String>.generate(
            10, (index) => (DateTime.now().year - index).toString());

        selected =
            await SimpleUIs().showGeneralDialogFunc(context, _list, selected);
        if (selected != -1) {
          SimpleUIs().showProgressIndicator(context);
          await Firestore.getStatisticks(
                  context: context, year: _list[selected])
              .then((value) {
            if (value != null) {
              for (int i = 0; i < value.length; i++) {
                var item = value[i];
                orders.add(item['payments']);
                months.add(item['month']);
              }
            }
          });
          for (var anan = 0; anan < orders.length; anan++) {
            for (var item in orders[anan]) {
              Order order = Order.fromJson(item);
              List<Food> listFood = List<Food>.generate(order.foods!.length,
                  (index) => Food.fromJson(order.foods![index]));
              for (var food in listFood) {
                int index = allFoods
                    .indexWhere((element) => element['name'] == food.name);
                if (index == -1) {
                  allFoods.add({
                    'name': food.name,
                    'count': food.count,
                    'price': double.parse(food.price)
                  });
                } else {
                  allFoods[index]['count'] =
                      allFoods[index]['count'] + food.count;

                  allFoods[index]['price'] =
                      allFoods[index]['price'] + double.parse(food.price);
                }
              }
            }
          }
          Navigator.pop(context);
          setState(() {});
        }
      },
    );
  }

  InkWell widgetFilter(String text, Function() func) {
    return InkWell(
      onTap: func,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style:
                Theme.of(context).textTheme.subtitle1!.copyWith(color: color4),
          ),
          const Icon(
            Icons.sort_rounded,
            color: color4,
          )
        ],
      ),
    );
  }

  //FUNCTİONS//---------------

  void list(index, monthIndex, StateSetter setState) {
    chartDatas = [];
    charts = [];
    maximum = 0;
    month = monthsString[monthIndex - 1];
    for (var item in orders[index]) {
      Order order = Order.fromJson(item);
      List<Food> listFood = List<Food>.generate(
          order.foods!.length, (index) => Food.fromJson(order.foods![index]));
      for (var food in listFood) {
        int index =
            chartDatas.indexWhere((element) => element['name'] == food.name);
        if (index == -1) {
          chartDatas.add({'name': food.name, 'count': food.count});
        } else {
          chartDatas[index]['count'] = chartDatas[index]['count'] + food.count;
        }
      }
    }
    for (var chartData in chartDatas) {
      if (chartData['count'] > maximum) {
        maximum = chartData['count'].toDouble();
      }
      charts.add(_ChartData(
          x: chartData['name'] + "\n${chartData['count']}",
          y: chartData['count'].toDouble()));
    }
    do {
      maximum++;
    } while (maximum % interval == 0);
    setState(() {});
  }

  void list2(int whichfood, StateSetter setState) {
    salesDatas = [];
    List liste = [];

    for (var item in monthsString) {
      salesDatas.add(SalesData(item, 1));
    }

    for (var i = 0; i < months.length; i++) {
      liste = [];
      for (var item in orders[i]) {
        Order order = Order.fromJson(item);
        List<Food> listFood = List<Food>.generate(
            order.foods!.length, (a) => Food.fromJson(order.foods![a]));
        for (var food in listFood) {
          if (food.name == allFoods[whichfood]['name']) {
            int index =
                liste.indexWhere((element) => element['name'] == food.name);
            if (index == -1) {
              liste.add({'name': food.name, 'count': food.count});
            } else {
              liste[index]['count'] = liste[index]['count'] + food.count;
            }
          }
        }
      }
      if (liste.isNotEmpty) {
        salesDatas[i].sales=liste[0]['count'].toDouble();
      } else {
        salesDatas[i].sales=0;
      }
    }
    setState(() {});
  }

  void list3(setState) {
    for (var i = 0; i < orders.length; i++) {
      for (var item in orders[i]) {
        int counter = 0;
        for (var item in item['foods']) {
          counter += item['count'] as int;
        }
        chartData[i].y = counter.toDouble();
      }
    }
    setState(() {});
  }
}

class _ChartData {
  _ChartData({required this.x, required this.y});

  final String x;
  final double y;
}

class SalesData {
  SalesData(
    this.month,
    this.sales,
  );
  final String month;
  double sales;
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  String x;
  double y;
  Color? color;
}
