import 'package:chef_gram_admin/utils/graphs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../database_service.dart';

class DailyTargetPage extends StatelessWidget {
  const DailyTargetPage({Key? key, required this.data}) : super(key: key);
  final Map data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Analysis"),
      ),
      body: ListView.builder(
          itemCount: this.data.keys.length,
          itemBuilder: (BuildContext context, int i) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 45.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${this.data.keys.toList()[i]}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        Text(
                            'Daily Target: ₹${(Provider.of<DatabaseService>(context, listen: false).employeeData[this.data.keys.toList()[i]] ~/ 30)}',
                            style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  Container(
                    width: 50.w,
                    height: 20.h,
                    child: EmployeeRadialGraph(
                        this.data[this.data.keys.toList()[i]],
                        Provider.of<DatabaseService>(context, listen: false)
                            .employeeData[this.data.keys.toList()[i]]),
                  )
                ],
              ),
            );
          }),
    );
  }
}
