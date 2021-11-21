import 'package:chef_gram_admin/models/profile_model.dart';
import 'package:chef_gram_admin/screens/Dashboard/profile.dart';
import 'package:chef_gram_admin/screens/auth/register_employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'create_target.dart';

class ShowEmployees extends StatefulWidget {
  @override
  _ShowEmployeesState createState() => _ShowEmployeesState();
}

class _ShowEmployeesState extends State<ShowEmployees> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Add Employee'),
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddEmployee()));
          },
        ),
        appBar: AppBar(
          title: Text("Employee Information"),
        ),
        body: Center(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: ListView(children: <Widget>[
                  ...snapshot.data!.docs.map(
                    (document) {
                      if (document['role'] == "employee") {
                        return SingleChildScrollView(
                          child: ExpansionTile(
                            title: Text(
                              document['name'],
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 2.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      child: Text(
                                        "Profile",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                              id: document.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    GestureDetector(
                                      child: Text(
                                        "Create Target",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CreateTarget(
                                              id: document.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: 0,
                        );
                      }
                    },
                  ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
