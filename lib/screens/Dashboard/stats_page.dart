import 'package:chef_gram_admin/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.orderData}) : super(key: key);

  final List orderData;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Widget> getConditions() {
    Filters filter =
        Provider.of<DatabaseService>(context, listen: false).filters;
    if (filter.state == null &&
        filter.city == null &&
        filter.beat == null &&
        filter.employee == null) {
      return [Text('PieChart'), Text("BarGraph"), Text("DateTimeAxis")];
    } else if (filter.city == null &&
        filter.beat == null &&
        filter.employee == null) {
      return [Text("BarGraph"), Text("DateTimeAxis")];
    } else if (filter.city == null &&
        filter.beat == null &&
        filter.employee == null) {
      return [Text("BarGraph"), Text("DateTimeAxis")];
    } else if (filter.beat == null && filter.employee == null) {
      return [Text("PieChart"), Text("BarGraph")];
    } else if (filter.employee == null) {
      return [Text("BarGraph")];
    } else if (filter.state == null &&
        filter.city == null &&
        filter.beat == null) {
      return [Text("DateTimeAxis")];
    } else if (filter.city == null && filter.beat == null) {
      return [Text("PieChart"), Text("DateTimeAxis")];
    } else if (filter.beat == null) {
      return [Text("TBD")];
    }

    return [Text("Noice")];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Analysis"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: getConditions(),
        ),
      ),
    );
  }
}
