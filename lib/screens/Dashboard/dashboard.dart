import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../authentication_service.dart';
import '../../database_service.dart';
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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: <Color>[Colors.indigo, Colors.indigoAccent]),
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                  Text("Admin",
                      style: TextStyle(color: Colors.white, fontSize: 17.sp))
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Item Catalog',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Catalog()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Order History',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Orders(isFromHome: true)));
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Employee List',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
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
        child: Container(height: 40.h, child: Text("NoiceNoice Graphs")),
      ),
    );
  }
}
