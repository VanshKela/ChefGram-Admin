import 'package:chef_gram_admin/screens/Employee/report_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();
  Future<List> getReports() async {
    var doc = await FirebaseFirestore.instance
        .collection('daily-reports')
        .where('name', isEqualTo: widget.name)
        .orderBy('dateTimeSubmitted', descending: true)
        .where('dateTimeSubmitted',
            isGreaterThanOrEqualTo: startDate, isLessThanOrEqualTo: endDate)
        .get();
    return doc.docs;
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {}

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Date"),
          content: SingleChildScrollView(
              child: Container(
            height: 50.h,
            width: 50.w,
            child: SfDateRangePicker(
              showActionButtons: true,
              onSelectionChanged: _onSelectionChanged,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(startDate, endDate),
              onCancel: () {
                setState(() {
                  startDate = DateTime(DateTime.now().year,
                      DateTime.now().month, DateTime.now().day)
                      .subtract(Duration(days: 7));
                  endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
              onSubmit: (Object value) {
                if (value is PickerDateRange) {
                  setState(() {
                    startDate = value.startDate!;
                    endDate = value.endDate!.add(Duration(days: 1));
                  });
                  Navigator.pop(context);
                }
              },
            ),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Report"),
        actions: [
          IconButton(onPressed: _showDialog, icon: Icon(Icons.calendar_today))
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getReports(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Container(
                height: 100.h,
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Report(snapshot: snapshot.data[index])));
                            },
                            leading:
                                CircleAvatar(child: Icon(Icons.date_range)),
                            title: Text(
                              snapshot.data[index]['date'],
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            subtitle: Text(
                              snapshot.data[index]['totalSale'].toString(),
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ],
                      );
                    }),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
