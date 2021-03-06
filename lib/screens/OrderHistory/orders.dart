import 'package:chef_gram_admin/database_service.dart';
import 'package:chef_gram_admin/screens/OrderHistory/stats_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'order_summary.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key, required this.isFromHome}) : super(key: key);
  final bool isFromHome;

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List orderData = [];
  bool isDataFetched = false;
  @override
  Widget build(BuildContext context) {
    if (widget.isFromHome)
      Provider.of<DatabaseService>(context).filters.reset();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo.shade50,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (isDataFetched && orderData.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StatsPage(orderData: orderData)));
            }
          },
          label: Row(
            children: [
              Icon(Icons.stacked_bar_chart),
              Text("Stats"),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("Order History"),
          actions: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return FilterPage();
                    });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Icon(Icons.filter_list_outlined),
                    Text(
                      "Filter",
                      style: TextStyle(fontSize: 12.sp),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        body: StreamBuilder(
          stream: Provider.of<DatabaseService>(context).filters.stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            if (snapshot.connectionState == ConnectionState.active) {
              isDataFetched = true;
              orderData = snapshot.data!.docs;
            }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: ListTile(
                    title: Text(
                      order['shopName'],
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "For: ${order['customerName']}",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Text(
                              "By: ${order['orderTakenBy']}",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xff00873C),
                              child: Icon(
                                FontAwesomeIcons.rupeeSign,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: Text(
                                order['total'].toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
              initialSelectedRange: PickerDateRange(
                  Provider.of<DatabaseService>(context, listen: false)
                      .filters
                      .startDate,
                  Provider.of<DatabaseService>(context, listen: false)
                      .filters
                      .endDate),
              onCancel: () {
                Provider.of<DatabaseService>(context, listen: false)
                    .filters
                    .updateDates(
                        DateTime(DateTime.now().year, DateTime.now().month,
                                DateTime.now().day)
                            .subtract(Duration(days: 6)),
                        DateTime.now());
                Navigator.pop(context);
              },
              onSubmit: (Object value) {
                if (value is PickerDateRange) {
                  Provider.of<DatabaseService>(context, listen: false)
                      .filters
                      .updateDates(value.startDate!,
                          value.endDate!.add(Duration(days: 1)));
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            ),
          )),
        );
      },
    );
  }

  static CollectionReference stateCollection =
      FirebaseFirestore.instance.collection('states');

  bool applyFilter = false;
  var state;
  var city;
  var beat;
  var employee;

  List<String> beats = [];
  List<String> stateList = [];
  List<String> cityList = [];
  List<String> empList = [];

  void getEmpList() async {
    List<String> _empList = [];
    var userRef = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();
    userRef.docs.forEach((element) {
      _empList.add(element.get('name'));
    });
    setState(() {
      empList = _empList;
    });
  }

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
    getEmpList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var startDate = Provider.of<DatabaseService>(context).filters.startDate;
    var endDate = Provider.of<DatabaseService>(context).filters.endDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Date Range:",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 40.w,
                    child: Text(
                        "${startDate.day.toString()}-${startDate.month.toString()}-${startDate.year.toString()} to ${endDate.day.toString()}-${endDate.month.toString()}-${endDate.year.toString()}"),
                  ),
                  Container(
                    width: 5.w,
                    child: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _showDialog();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Employee:",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: employee,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 28,
                elevation: 20,
                onChanged: (String? newval) {
                  setState(() {
                    employee = newval;
                  });
                },
                items: empList.map<DropdownMenuItem<String>>((String value) {
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
                Provider.of<DatabaseService>(context, listen: false)
                    .filters
                    .reset();
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Orders(isFromHome: false)));
              },
            ),
            ElevatedButton(
              child: const Text('Apply Filter'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green)),
              onPressed: () {
                Provider.of<DatabaseService>(context, listen: false)
                    .filters
                    .update(
                        state: state,
                        city: city,
                        beat: beat,
                        employee: employee);
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Orders(isFromHome: false)));
              },
            ),
          ],
        ),
      ],
    );
  }
}
