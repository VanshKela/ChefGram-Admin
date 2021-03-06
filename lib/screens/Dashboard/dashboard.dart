import 'dart:math';

import 'package:chef_gram_admin/models/profile_model.dart';
import 'package:chef_gram_admin/screens/TakeOrder/take_order.dart';
import 'package:chef_gram_admin/utils/graphs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../authentication_service.dart';
import '../../database_service.dart';
import '../../main.dart';
import '../Shops/add_beat.dart';
import '../Shops/add_shops.dart';
import '../Employee/daily_target_list.dart';
import '../Shops/manage_shop.dart';
import '../Employee/employee_list.dart';
import '../OrderHistory/orders.dart';
import '../Catalog/catalog.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List orderData = [];
  bool isDataFetched = false;
  late String appVerison;
  List<Widget> targetDailyWidgetList = [];
  Map<String, dynamic> employeeSalesMap = {};
  void calculateSales() async {
    List<Widget> _targetDailyWidgetList = [];
    Map<String, dynamic> _employeeSalesMap = {};
    Map<String, dynamic> employeeData =
        await Provider.of<DatabaseService>(context, listen: false)
            .getEmployeeData();
    for (String key in employeeData.keys) {
      _employeeSalesMap[key] = 0.0;
    }

    for (var order in orderData) {
      if (_employeeSalesMap.containsKey(order['orderTakenBy'])) {
        _employeeSalesMap[order['orderTakenBy']] += order['total'];
      }
    }

    for (int i = 0; i < _employeeSalesMap.keys.length; i++) {
      _targetDailyWidgetList.add(Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 18.h,
              child: EmployeeRadialGraph(
                _employeeSalesMap[_employeeSalesMap.keys.toList()[i]],
                Provider.of<DatabaseService>(context, listen: false)
                    .employeeData[_employeeSalesMap.keys.toList()[i]],
              )),
          Container(
            height: 3.h,
            child: Text(
              '${_employeeSalesMap.keys.toList()[i]}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ));
    }
    setState(() {
      targetDailyWidgetList = _targetDailyWidgetList;
      employeeSalesMap = _employeeSalesMap;
    });
  }

  @override
  void initState() {
    Provider.of<DatabaseService>(context, listen: false).getEmployeeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<DatabaseService>(context).getEmployeeData();
    DateTime startDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return FirebaseAuth.instance.currentUser!.uid !=
            Provider.of<DatabaseService>(context, listen: false).uid
        ? MyApp()
        : Scaffold(
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
                          style:
                              TextStyle(color: Colors.white, fontSize: 12.sp),
                        ),
                        Container(
                          child: Text(
                              Provider.of<Profile>(context, listen: true).name,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 17.sp)),
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
                    leading: Icon(Icons.add),
                    title: Text('Take Order',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => TakeOrder()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Employee List',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShowEmployees()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Add Beat',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddBeat()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Add Shops',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddShop()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Delete/Edit Shops',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DeleteShop()));
                    },
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
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('dateTime', isGreaterThanOrEqualTo: startDate)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  isDataFetched = true;
                  orderData = snapshot.data!.docs;
                  calculateSales();
                }
                return SingleChildScrollView(
                  child: Container(
                    child: !isDataFetched
                        ? CircularProgressIndicator()
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right: 2.h, left: 2.h, top: 1.h),
                                child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.25),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        color: Colors.white38,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: DailyLineGraph(orderData, context)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: Text(
                                  "Daily Progress",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              (targetDailyWidgetList.length > 0)
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DailyTargetPage(
                                                        data:
                                                            employeeSalesMap)));
                                      },
                                      child: Container(
                                        height: 27.h *
                                            ((min(
                                                        4,
                                                        targetDailyWidgetList
                                                            .length) +
                                                    1) ~/
                                                2),
                                        width: 100.w,
                                        child: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                            ),
                                            itemCount: min(4,
                                                targetDailyWidgetList.length),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 5,
                                                            blurRadius: 7,
                                                            offset: Offset(0,
                                                                3), // changes position of shadow
                                                          ),
                                                        ],
                                                        color: Colors.white38,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: SingleChildScrollView(
                                                        child:
                                                            targetDailyWidgetList[
                                                                index])),
                                              );
                                            }),
                                      ),
                                    )
                                  : CircularProgressIndicator(),
                            ],
                          ),
                  ),
                );
              },
            ),
          );
  }
}
