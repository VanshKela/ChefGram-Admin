import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sizer/sizer.dart';

import '../database_service.dart';

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final int y;
}

Widget DayBasedLineGraph(List orderData, BuildContext context) {
  List<_ChartData> chartData = [];
  DateTime startDate =
      Provider.of<DatabaseService>(context, listen: false).filters.startDate;
  int dayDiff = Provider.of<DatabaseService>(context, listen: false)
      .filters
      .endDate
      .difference(startDate)
      .inDays;

  Map<String, int> orderMap = {};
  for (int i = 0; i <= dayDiff; i++) {
    DateTime newDay = startDate.add(Duration(days: i));
    String key = "${newDay.day}-${newDay.month}";
    orderMap['$key'] = 0;
  }
  orderData.forEach((order) {
    DateTime dateTime = order['dateTime'].toDate();
    String key = "${dateTime.day}-${dateTime.month}";
    orderMap['$key'] = (orderMap['$key']! + order['total']) as int;
  });
  orderMap.forEach((key, value) {
    chartData.add(_ChartData(key, value));
  });
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Container(
      child: Column(
        children: [
          SizedBox(
            height: 1.h,
          ),
          Text(
            "Daily Sales",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              tooltipBehavior: _tooltip,
              series: <ChartSeries>[
                LineSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_ChartData sales, _) => sales.x,
                  yValueMapper: (_ChartData sales, _) => sales.y,
                ),
              ]),
        ],
      ),
    ),
  );
}

Widget StatePieChart(List orderData) {
  var totalSale = 0.0;
  List<_ChartData> chartData = [];
  Map<String, int> orderMap = {};
  orderData.forEach((order) {
    totalSale += order['total'];
    if (orderMap.containsKey(order['state']))
      orderMap[order['state']] =
          (orderMap[order['state']]! + order['total']) as int;
    else
      orderMap[order['state']] = order['total'];
  });
  orderMap.forEach((key, value) {
    chartData.add(_ChartData(key, value));
  });
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Column(
      children: [
        Text("State Based Analysis",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        Container(
            child: SfCircularChart(
                tooltipBehavior: _tooltip,
                series: <CircularSeries>[
              // Render pie chart
              PieSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                dataLabelMapper: (_ChartData data, _) {
                  return "${data.x}: ${(data.y / totalSale * 100).toStringAsFixed(2)}%";
                },
                dataLabelSettings: DataLabelSettings(isVisible: true),
              )
            ])),
      ],
    ),
  );
}

Widget EmployeeBarGraph(List orderData, BuildContext context) {
  List<_ChartData> data = [];
  Map<String, int> orderMap = {};
  orderData.forEach((order) {
    if (orderMap.containsKey(order['orderTakenBy']))
      orderMap[order['orderTakenBy']] =
          (orderMap[order['orderTakenBy']]! + order['total']) as int;
    else
      orderMap[order['orderTakenBy']] = order['total'];
  });
  orderMap.forEach((key, value) {
    data.add(_ChartData(key, value));
  });
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Column(
      children: [
        Text("Employee-vise Sales",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
                width: data.length < 8 ? 100.w : 100.0 * data.length,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: orderMap.values.reduce(max).toDouble(),
                        interval: 1000),
                    tooltipBehavior: _tooltip,
                    series: <ChartSeries<_ChartData, String>>[
                      ColumnSeries<_ChartData, String>(
                          dataSource: data,
                          xValueMapper: (_ChartData data, _) =>
                              data.x.length < 10
                                  ? data.x
                                  : data.x.substring(0, 10),
                          yValueMapper: (_ChartData data, _) => data.y,
                          name: 'Gold',
                          color: Color.fromRGBO(8, 142, 255, 1))
                    ])),
          ),
        ),
      ],
    ),
  );
}

Widget CityPieChart(List orderData) {
  var totalSale = 0.0;
  List<_ChartData> chartData = [];
  Map<String, int> orderMap = {};
  orderData.forEach((order) {
    totalSale += order['total'];
    if (orderMap.containsKey(order['city']))
      orderMap[order['city']] =
          (orderMap[order['city']]! + order['total']) as int;
    else
      orderMap[order['city']] = order['total'];
  });
  orderMap.forEach((key, value) {
    chartData.add(_ChartData(key, value));
  });
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Column(
      children: [
        Text("City Based Analysis",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        Container(
            width: 200.w,
            child: SfCircularChart(
                tooltipBehavior: _tooltip,
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    dataLabelMapper: (_ChartData data, _) {
                      return "${data.x}: ${(data.y / totalSale * 100).toStringAsFixed(2)}%";
                    },
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  )
                ])),
      ],
    ),
  );
}

Widget BeatBarGraph(List orderData) {
  List<_ChartData> data = [];
  Map<String, int> orderMap = {};
  orderData.forEach((order) {
    if (orderMap.containsKey(order['beat']))
      orderMap[order['beat']] =
          (orderMap[order['beat']]! + order['total']) as int;
    else
      orderMap[order['beat']] = order['total'];
  });
  orderMap.forEach((key, value) {
    data.add(_ChartData(key, value));
  });
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Text("Beat-vise Analysis",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            Container(
                width: data.length < 8 ? 100.w : 100.0 * data.length,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: orderMap.values.reduce(max).toDouble(),
                        interval: 1000),
                    tooltipBehavior: _tooltip,
                    series: <ChartSeries<_ChartData, String>>[
                      ColumnSeries<_ChartData, String>(
                          dataSource: data,
                          xValueMapper: (_ChartData data, _) =>
                              data.x.length < 10
                                  ? data.x
                                  : data.x.substring(0, 10),
                          yValueMapper: (_ChartData data, _) => data.y,
                          name: 'Gold',
                          color: Color.fromRGBO(8, 142, 255, 1))
                    ])),
          ],
        ),
      ),
    ),
  );
}

Widget DailyLineGraph(List orderData, BuildContext context) {
  List<_ChartData> chartData = [];
  DateTime startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int hourDiff = DateTime.now().difference(startDate).inHours;
  Map<String, int> orderMap = {};
  for (int i = 0; i <= hourDiff; i++) {
    DateTime newDay = startDate.add(Duration(hours: i));

    String key = "${newDay.hour}:00";
    orderMap['$key'] = 0;
  }

  orderData.forEach((order) {
    DateTime dateTime = order['dateTime'].toDate();
    String key = "${dateTime.hour}:00";

    orderMap['$key'] = (orderMap['$key']! + order['total']) as int;
  });
  orderMap.forEach((key, value) {
    chartData.add(_ChartData(key, value));
  });
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Container(
      child: Column(
        children: [
          SizedBox(
            height: 1.h,
          ),
          Text(
            "Hourly Sales",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 25.h,
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                tooltipBehavior: _tooltip,
                series: <ChartSeries>[
                  LineSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData sales, _) => sales.x,
                    yValueMapper: (_ChartData sales, _) => sales.y,
                  ),
                ]),
          ),
        ],
      ),
    ),
  );
}
