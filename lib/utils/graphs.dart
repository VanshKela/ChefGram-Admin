import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sizer/sizer.dart';

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final int y;
}

Widget DayBasedLineGraph(List orderData) {
  final List<_ChartData> chartData = [
    _ChartData("YO", 35),
    _ChartData("YO1", 28),
    _ChartData("YO2", 34),
    _ChartData("YO3", 32),
    _ChartData("YO4", 40)
  ];
  return Container(
    child: SfCartesianChart(primaryXAxis: CategoryAxis(), series: <ChartSeries>[
      // Renders line chart
      LineSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y)
    ]),
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
  return Container(
      width: 200.w,
      child: SfCircularChart(series: <CircularSeries>[
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
      ]));
}

Widget EmployeeBarGraph(List orderData) {
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
  return Scrollbar(
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
                        data.x.length < 10 ? data.x : data.x.substring(0, 10),
                    yValueMapper: (_ChartData data, _) => data.y,
                    name: 'Gold',
                    color: Color.fromRGBO(8, 142, 255, 1))
              ])),
    ),
  );
}
