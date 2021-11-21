import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfilePage extends StatefulWidget {
  final String id;

  const ProfilePage({Key? key, required this.id}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String employeeName = '';
  String employeeAge = '';
  String empEmail = '';
  String empLocation = '';
  var monthlyTarget = 0;
  var monthlySales = 0.0;
  var dailySales = 0.0;
  var totalSales = 0.0;

  void calculateSales(snapshot) async {
    monthlySales = 0.0;
    dailySales = 0.0;
    totalSales = 0.0;
    for (var order in snapshot.data.docs) {
      Timestamp time = order.get('dateTime');
      monthlySales += order.get('total');
      if (time.toDate().day == DateTime.now().day) {
        dailySales += order.get('total');
      }
    }
  }

  void getEmployeeData() async {
    var document = await users.doc(widget.id).get();
    setState(() {
      employeeName = document['name'];
      employeeAge = document['age'].toString();
      // empEmail = document['email'];
      // empLocation = document['location'];
      monthlyTarget = document['monthlyTarget'];
    });
  }

  @override
  initState() {
    getEmployeeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('orderTakenBy', isEqualTo: employeeName)
                  .where('dateTime',
                      isGreaterThanOrEqualTo:
                          DateTime(DateTime.now().year, DateTime.now().month))
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData &&
                    employeeAge.isEmpty &&
                    employeeName.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  calculateSales(snapshot);
                }
                final List<_ChartData> chartData = <_ChartData>[
                  _ChartData(
                      'Daily Sale',
                      (dailySales / (monthlyTarget ~/ 30)) * 100,
                      const Color.fromRGBO(235, 97, 143, 1),
                      "${((dailySales / 6000) * 100).toStringAsFixed(2)} %"),
                  _ChartData(
                      'Monthly Sale',
                      (monthlySales / monthlyTarget) * 100,
                      const Color.fromRGBO(145, 132, 202, 1),
                      "${((monthlySales / monthlyTarget) * 100).toStringAsFixed(2)} %"),
                ];
                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Container(
                      width: 100.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employeeName,
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Age: ${employeeAge}",
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            height: 65.h,
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: "Completion Target (In %)",
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                legend: Legend(
                                    isVisible: true,
                                    iconHeight: 5.h,
                                    iconWidth: 10.w,
                                    textStyle: TextStyle(fontSize: 14.sp),
                                    overflowMode: LegendItemOverflowMode.wrap),
                                series: <CircularSeries<_ChartData, String>>[
                                  RadialBarSeries<_ChartData, String>(
                                      maximumValue: 100,
                                      radius: '100%',
                                      gap: '3%',
                                      dataSource: chartData,
                                      cornerStyle: CornerStyle.bothCurve,
                                      xValueMapper: (_ChartData data, _) =>
                                          data.xData,
                                      yValueMapper: (_ChartData data, _) =>
                                          data.yData,
                                      dataLabelSettings: DataLabelSettings(
                                          isVisible: true,
                                          textStyle: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      dataLabelMapper: (_ChartData data, _) =>
                                          data.text,
                                      pointColorMapper: (_ChartData data, _) =>
                                          data.color),
                                ]),
                          ),
                          Text(
                            "Monthly Sales: ${monthlySales.toString()}",
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "Daily Sales: ${dailySales.toString()}",
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.xData, this.yData, this.color, this.text);

  final String xData;
  final num yData;
  final Color color;
  final String text;
}
