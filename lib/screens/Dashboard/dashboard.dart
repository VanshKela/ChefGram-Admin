import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../authentication_service.dart';
import 'orders.dart';
import 'catalog.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    List<ElevatedButton> buttons = [
      ElevatedButton(
        child: Text(
          "Show Catalog",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Catalog()));
        },
      ),
      ElevatedButton(
        child: Text(
          "Show All Orders",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Orders(isFromHome: true)));
        },
      ),
      ElevatedButton(
        child: Text(
          "Show Employees",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
        onPressed: () {},
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<AuthenticationService>(context, listen: false)
                    .signOut();
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Container(
          height: 40.h,
          child: GridView.count(
            primary: false,
            childAspectRatio: (1 / .2),
            crossAxisCount: 1,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: buttons,
          ),
        ),
      ),
    );
  }
}

