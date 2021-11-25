import 'package:chef_gram_admin/database_service.dart';
import 'package:chef_gram_admin/utils/graphs.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:io';
import 'package:open_file/open_file.dart';

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

  void getExcel() async{
    final xlsio.Workbook workbook = new xlsio.Workbook();
    workbook.worksheets[0];
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true).then((value) {
      OpenFile.open(fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate =
        Provider.of<DatabaseService>(context, listen: false).filters.startDate;
    DateTime endDate =
        Provider.of<DatabaseService>(context, listen: false).filters.endDate;
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: getExcel, icon: Icon(Icons.download))],
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
