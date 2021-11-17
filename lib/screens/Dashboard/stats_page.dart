import 'dart:math';

import 'package:chef_gram_admin/database_service.dart';
import 'package:chef_gram_admin/utils/graphs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.orderData}) : super(key: key);

  final List orderData;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Widget> getConditions() {
    List<Widget> graphs = [];
    Filters filter =
        Provider.of<DatabaseService>(context, listen: false).filters;
    graphs.add(DayBasedLineGraph(widget.orderData, context));
    if (filter.employee == null)
      graphs.add(EmployeeBarGraph(widget.orderData, context));
    if (filter.state == null)
      graphs.add(StatePieChart(widget.orderData));
    else if (filter.city == null)
      graphs.add(CityPieChart(widget.orderData));
    else if (filter.beat == null) graphs.add(BeatBarGraph(widget.orderData));
    return graphs;
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate =
        Provider.of<DatabaseService>(context, listen: false).filters.startDate;
    DateTime endDate =
        Provider.of<DatabaseService>(context, listen: false).filters.endDate;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "Analysis ${"${startDate.day}-${startDate.month}-${startDate.year}"} to ${"${endDate.day}-${endDate.month}-${endDate.year}"}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: getConditions(),
        ),
      ),
    );
  }
}
