import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class Report extends StatelessWidget {
  const Report({Key? key, required this.snapshot}) : super(key: key);
  final snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report for ${snapshot.get('date')}"),
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.get('shopDetails').length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: snapshot.get('shopDetails')[index]['isVisited']
                                ? snapshot.get('shopDetails')[index]["orderSuccessful"]
                                    ? Colors.green
                                    : Colors.deepPurple
                                : Colors.red,
                            child: Icon(snapshot.get('shopDetails')[index]['isVisited']
                                ? snapshot.get('shopDetails')[index]["orderSuccessful"]
                                    ? FontAwesomeIcons.checkDouble
                                    : Icons.check
                                : Icons.clear),
                            foregroundColor: Colors.white,
                          ),
                          title: Text(
                            snapshot.get('shopDetails')[index]['shopName'],
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.get('shopDetails')[index]['shopOwner'],
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              Text(
                                snapshot.get('shopDetails')[index]['comment'],
                                style: TextStyle(fontSize: 10.sp),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Column(
            children: [
              Text("Total Sale"),
              Text(
                "₹ ${snapshot.get('totalSale')}",
                style:
                TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),

    );
  }
}
