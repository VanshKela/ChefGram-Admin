import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'order_summary.dart';

var state;
var city;
var beat;

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getStream() {
    if (state == null) {
      return FirebaseFirestore.instance.collection('orders').snapshots();
    } else {
      if (city == null) {
        return FirebaseFirestore.instance
            .collection('orders')
            .where('state', isEqualTo: state)
            .snapshots();
      } else {
        if (beat == null) {
          return FirebaseFirestore.instance
              .collection('orders')
              .where('state', isEqualTo: state)
              .where('city', isEqualTo: city)
              .snapshots();
        } else {
          return FirebaseFirestore.instance
              .collection('orders')
              .where('state', isEqualTo: state)
              .where('city', isEqualTo: city)
              .where('beat', isEqualTo: beat)
              .snapshots();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return FilterPage();
                });
          },
          label: Row(
            children: [Icon(Icons.filter_list_outlined), Text("Filter")],
          ),
        ),
        body: StreamBuilder(
          stream: getStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            print("Length: ${snapshot.data!.docs.length}");
            return Container(
              child: (snapshot.data!.docs.length == 0)
                  ? Center(
                      child: Text(
                      "No orders Placed Today",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ))
                  : ListView(
                      children: <Widget>[
                        ...snapshot.data!.docs.map((order) {
                          return SingleOrderWidget(order: order);
                        })
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class SingleOrderWidget extends StatelessWidget {
  SingleOrderWidget({required this.order});

  var order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OrderSummary(order: order);
            },
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Container(
          width: 100.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Customer Name : ${order['customerName']}",
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "By: ${order['orderTakenBy']}",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        Text(
                          "Shop : ${order['shopName']}",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹ ${order['total']}",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  static CollectionReference stateCollection =
      FirebaseFirestore.instance.collection('states');

  bool applyFilter = false;

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
        .collection('states/${state.replaceAll(' ', '')}/cities')
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
        .collection('states/${state.replaceAll(' ', '')}/cities')
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
    return Column(
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
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
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
                items: stateList.map<DropdownMenuItem<String>>((String value) {
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
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
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
                items: cityList.map<DropdownMenuItem<String>>((String value) {
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
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
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
                items: beats.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: const Text('Remove Filter'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)),
              onPressed: () {
                state = null;
                city = null;
                beat = null;
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Orders()));
              },
            ),
            ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Orders()));
              },
            ),
          ],
        ),
      ],
    );
  }
}