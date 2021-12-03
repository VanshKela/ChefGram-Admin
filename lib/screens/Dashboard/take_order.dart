import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:sizer/sizer.dart';
import '';
import 'choose_from_catalog.dart';

class TakeOrder extends StatefulWidget {
  const TakeOrder({Key? key}) : super(key: key);

  @override
  _TakeOrderState createState() => _TakeOrderState();
}

class _TakeOrderState extends State<TakeOrder> {
  static CollectionReference stateCollection =
      FirebaseFirestore.instance.collection('states');
  var state;
  var city;
  var beat;
  var shop;

  List<String> beats = [];
  List<String> stateList = [];
  List<String> cityList = [];
  List<String> shops = [];

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
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

  Future<void> getShop() async {
    var shopCollection = await FirebaseFirestore.instance
        .collection('shops')
        .where('city', isEqualTo: city)
        .where('state', isEqualTo: state)
        .where('beat', isEqualTo: beat)
        .get();
    List<String> _shops = [];
    shopCollection.docs.forEach((shop) {
      _shops.add(shop['shopName']);
    });
    setState(() {
      shops = _shops;
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
          centerTitle: true,
          title: Text("Choose Beat"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                                shop = null;
                                cityList.clear();
                                beats.clear();
                                shops.clear();
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
                                shop = null;
                                shops.clear();
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
                                shop = null;
                              });
                              getShop();
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Shop:",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: shop,
                            icon: Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            elevation: 20,
                            onChanged: (String? newval) {
                              setState(() {
                                shop = newval;
                              });
                            },
                            items: shops
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
              ElevatedButton(
                child: Text("Continue"),
                onPressed: () async {
                  if (state != null &&
                      city != null &&
                      beat != null &&
                      shop != null) {
                    Loader.show(context);
                    await FirebaseFirestore.instance
                        .collection('shops')
                        .where('state', isEqualTo: state)
                        .where('city', isEqualTo: city)
                        .where('beat', isEqualTo: beat)
                        .where('shopName', isEqualTo: shop)
                        .get()
                        .then((value) async {
                      Loader.hide();
                      await FirebaseFirestore.instance
                          .collection('shops')
                          .doc(value.docs.first.id)
                          .get()
                          .then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseFromCatalog(
                                      shopDetails: value.data(),
                                    )));
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Select all fields first!"),
                      backgroundColor: Colors.red,
                      duration: Duration(milliseconds: 600),
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
