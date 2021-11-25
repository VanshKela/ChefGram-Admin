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
    xlsio.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByIndex(1, 1).setText('Shop Name');
    sheet.getRangeByIndex(1, 2).setText('Customer Name');
    sheet.getRangeByIndex(1, 3).setText('State');
    sheet.getRangeByIndex(1, 4).setText('City');
    sheet.getRangeByIndex(1, 5).setText('Beat');
    sheet.getRangeByIndex(1, 6).setText('Address');
    sheet.getRangeByIndex(1, 7).setText('Order Taken By');
    sheet.getRangeByIndex(1, 8).setText('Date Time');
    sheet.getRangeByIndex(1, 9).setText('Item');
    sheet.getRangeByIndex(1, 10).setText('Quantity (gm)');
    sheet.getRangeByIndex(1, 11).setText('Boxes');
    sheet.getRangeByIndex(1, 12).setText('Price');
    sheet.getRangeByIndex(1, 13).setText('Total');
    int row = 2;
    widget.orderData.forEach((order) {
      String shopName = order.get('shopName');
      String customerName = order.get('customerName');
      String state = order.get('state');
      String city = order.get('city');
      String beat = order.get('beat');
      String address = order.get('address');
      String orderTakenBy = order.get('orderTakenBy');
      DateTime dateTime = order.get('dateTime').toDate();
      List items = order.get('items');
      for (int i=0; i<items.length;i++) {
        sheet.getRangeByIndex(row, 1).setText(shopName);
        sheet.getRangeByIndex(row, 2).setText(customerName);
        sheet.getRangeByIndex(row, 3).setText(state);
        sheet.getRangeByIndex(row, 4).setText(city);
        sheet.getRangeByIndex(row, 5).setText(beat);
        sheet.getRangeByIndex(row, 6).setText(address);
        sheet.getRangeByIndex(row, 7).setText(orderTakenBy);
        sheet.getRangeByIndex(row, 8).setDateTime(dateTime);
        sheet.getRangeByIndex(row, 9).setText(items[i]['name']);
        sheet.getRangeByIndex(row, 10).setText((items[i]['quantity']).toString());
        sheet.getRangeByIndex(row, 11).setText((items[i]['boxes']).toString());
        sheet.getRangeByIndex(row, 12).setText((items[i]['price']).toString());
        sheet.getRangeByIndex(row, 13).setText((items[i]['boxes'] * items[i]['price']).toString());
        row++;
      }
    });
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
