import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key, required this.name}) : super(key: key);
  final String name;
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Future<List> getReports() async {
    var doc = await FirebaseFirestore.instance
        .collection('daily-reports')
        .where('name', isEqualTo: widget.name)
        .orderBy('dateTimeSubmitted', descending: true)
        .where('dateTimeSubmitted',
            isGreaterThanOrEqualTo: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(Duration(days: 7)))
        .get();

    return doc.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Report"),
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
