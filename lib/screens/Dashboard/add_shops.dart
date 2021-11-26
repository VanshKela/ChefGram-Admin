import 'package:chef_gram_admin/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../database_service.dart';
import 'add_shop_to_beat.dart';

class AddShop extends StatefulWidget {
  const AddShop({Key? key}) : super(key: key);

  @override
  _AddShopState createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  static CollectionReference stateCollection =
      FirebaseFirestore.instance.collection('states');
  var state;
  var city;
  var beat;

  List<String> beats = [];
  List<String> stateList = [];
  List<String> cityList = [];
  void getStates() async {
    List<String> _stateList = [];
    var statesRef = await stateCollection.get();
    statesRef.docs.forEach((state) {
      _stateList.add(state.get('stateName'));
    });
    setState(() {
      stateList = _stateList;
    });
  }

  Future<void> getCities() async {
    List<String> _cityList = [];
    var cityCollection = await FirebaseFirestore.instance
        .collection('states/${state}/cities')
        .get();
    for (var city in cityCollection.docs) {
      _cityList.add(city['cityName']);
    }
    setState(() {
      cityList = _cityList;
    });
  }

  Future<void> getBeat() async {
    var beatCollection = await FirebaseFirestore.instance
        .collection('states/${state}/cities')
        .where('cityName', isEqualTo: city)
        .get();
    List<String> _beats = [];
    beatCollection.docs.first.get('beats').forEach((beat) {
      _beats.add(beat);
    });
    setState(() {
      beats = _beats;
    });
  }

  @override
  void initState() {
    getStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Shops"),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              Container(
                width: 100.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 6.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select State:",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: state,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            elevation: 20,
                            onChanged: (String? newval) {
                              setState(() {
                                state = newval;
                                city = null;
                                beat = null;
                                cityList.clear();
                                beats.clear();
                              });
                              getCities();
                            },
                            items: stateList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select City:",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: city,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            elevation: 20,
                            onChanged: (String? newval) {
                              setState(() {
                                city = newval;
                                beat = null;
                              });
                              getBeat();
                            },
                            items: cityList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Beat:",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: beat,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            elevation: 20,
                            onChanged: (String? newval) {
                              setState(() {
                                beat = newval;
                              });
                            },
                            items: beats
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                  ],
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: Text("Continue"),
                  onPressed: () {
                    if ((state != null) && (city != null) && (beat != null)) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddShopToBeat(
                                    state: state,
                                    city: city,
                                    beat: beat,
                                  )));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Select all Fields!"),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 1600),
                      ));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
