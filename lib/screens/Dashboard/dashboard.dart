import 'package:chef_gram_admin/models/profile_model.dart';
import 'package:chef_gram_admin/utils/graphs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List orderData = [];
  bool isDataFetched = false;
  @override
  Widget build(BuildContext context) {
    DateTime startDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
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
                  Container(
                    child: Text(
                        Provider.of<Profile>(context, listen: false).name,
                        style: TextStyle(color: Colors.white, fontSize: 17.sp)),
                  )
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('dateTime', isGreaterThanOrEqualTo: startDate)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.connectionState == ConnectionState.active) {
              isDataFetched = true;
              orderData = snapshot.data!.docs;
            }

            return Container(
              child: !isDataFetched
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        Container(child: DailyLineGraph(orderData, context))
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
