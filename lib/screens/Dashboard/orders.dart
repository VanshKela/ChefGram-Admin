import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  static CollectionReference stateCollection =
      FirebaseFirestore.instance.collection('states');
  var state;
  var city;
  var beat;
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
    return Scaffold(
      body: Center(
        child: Container(
          width: 100.w,
          child: applyFilter
              ? Filter()
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      applyFilter = !applyFilter;
                    });
                  },
                  child: Text("Apply Filter")),
        ),
      ),
    );
  }

  Column Filter() {
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
        ElevatedButton(
            onPressed: () {
              setState(() {
                applyFilter = !applyFilter;
              });
            },
            child: Text("Remove Filter")),
      ],
    );
  }
}
