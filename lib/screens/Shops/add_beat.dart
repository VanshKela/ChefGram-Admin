import 'dart:convert';

import 'package:chef_gram_admin/models/city_model.dart';
import 'package:chef_gram_admin/models/state_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:sizer/sizer.dart';


class AddBeat extends StatefulWidget {
  const AddBeat({Key? key}) : super(key: key);

  @override
  _AddBeatState createState() => _AddBeatState();
}

class _AddBeatState extends State<AddBeat> {
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController beat = TextEditingController();
  List<StateModel> _stateList = [];
  List<CityModel> _cityList = [];
  List<StateModel> _stateSubList = [];
  List<CityModel> _citySubList = [];
  String _title = '';

  Future<void> _getState() async {
    _stateList.clear();
    _cityList.clear();
    List<StateModel> _subStateList = [];
    var jsonString = await rootBundle.loadString('assets/state.json');
    List<dynamic> body = json.decode(jsonString);

    _subStateList =
        body.map((dynamic item) => StateModel.fromJson(item)).toList();
    _subStateList.forEach((element) {
      setState(() {
        _stateList.add(element);
      });
    });
    _stateSubList = _stateList;
  }

  Future<void> _getCity(String stateId) async {
    _cityList.clear();
    List<CityModel> _subCityList = [];
    var jsonString = await rootBundle.loadString('assets/city.json');
    List<dynamic> body = json.decode(jsonString);

    _subCityList =
        body.map((dynamic item) => CityModel.fromJson(item)).toList();
    _subCityList.forEach((element) {
      if (element.stateId == stateId) {
        setState(() {
          _cityList.add(element);
        });
      }
    });
    _citySubList = _cityList;
  }

  void addBeatToCloud() async {
    if (state.text.isNotEmpty && city.text.isNotEmpty && beat.text.isNotEmpty) {
      var stateDoc = await FirebaseFirestore.instance
          .collection('states')
          .doc(state.text)
          .get();

      if (stateDoc.exists) {
        var cityDoc = await FirebaseFirestore.instance
            .collection('states')
            .doc(state.text)
            .collection('cities')
            .doc(city.text)
            .get();
        if (cityDoc.exists) {
          List beats = cityDoc.get('beats');
          if (beats.contains(beat.text)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Beat Already Exists"),
              backgroundColor: Colors.blue,
              duration: Duration(milliseconds: 600),
            ));
          } else {
            beats.add(beat.text);
            await FirebaseFirestore.instance
                .collection('states/${state.text}/cities')
                .doc(city.text)
                .update({'beats': beats});
          }
        } else {
          await FirebaseFirestore.instance
              .collection('states/${state.text}/cities')
              .doc(city.text)
              .set({
            'cityName': city.text,
            'beats': [beat.text]
          });
        }
      } else {
        await FirebaseFirestore.instance
            .collection('states')
            .doc(state.text)
            .set({
          "stateName": "${state.text}",
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection('states/${state.text}/cities')
              .doc(city.text)
              .set({
            'cityName': city.text,
            'beats': [beat.text]
          });
        });
      }
      // print(cityDoc);
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    _getState();
    super.initState();
  }

  @override
  void dispose() {
    state.dispose();
    city.dispose();
    beat.dispose();
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Beat"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 70.w,
            height: 70.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: state,
                  onTap: () {
                    setState(() => _title = 'State');
                    _showDialog(context);
                  },
                  decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Select State',
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder()),
                  readOnly: true,
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: city,
                  onTap: () {
                    setState(() => _title = 'City');
                    if (state.text.isNotEmpty)
                      _showDialog(context);
                    else
                      _showSnackBar('Select State');
                  },
                  decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Select City',
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder()),
                  readOnly: true,
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: beat,
                  decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Enter Beat',
                      border: OutlineInputBorder()),
                ),
                ElevatedButton(
                  child: Text("Add Beat"),
                  onPressed: () {
                    if (state.text.isNotEmpty &&
                        city.text.isNotEmpty &&
                        beat.text.isNotEmpty) {
                      Loader.show(context);
                      addBeatToCloud();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Select all fields'),
                        backgroundColor: Colors.red,
                        duration: Duration(milliseconds: 4000),
                      ));
                    }

                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddShops(data:data)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    TextEditingController _controller2 = TextEditingController();
    TextEditingController _controller3 = TextEditingController();

    showGeneralDialog(
      barrierLabel: _title,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, __, ___) {
        return Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * .7,
                  margin: EdgeInsets.only(top: 60, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(_title,
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 17,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 10),

                      ///Text Field
                      TextField(
                        controller: _title == 'Country'
                            ? _controller
                            : _title == 'State'
                                ? _controller2
                                : _controller3,
                        onChanged: (val) {
                          setState(() {
                            if (_title == 'State') {
                              _stateSubList = _stateList
                                  .where((element) => element.name
                                      .toLowerCase()
                                      .contains(
                                          _controller2.text.toLowerCase()))
                                  .toList();
                            } else if (_title == 'City') {
                              _citySubList = _cityList
                                  .where((element) => element.name
                                      .toLowerCase()
                                      .contains(
                                          _controller3.text.toLowerCase()))
                                  .toList();
                            }
                          });
                        },
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 16.0),
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: "Search here...",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 5),
                            isDense: true,
                            prefixIcon: Icon(Icons.search)),
                      ),

                      ///Dropdown Items
                      Expanded(
                        child: Container(
                          child: ListView.builder(
                            itemCount: _title == 'State'
                                ? _stateSubList.length
                                : _citySubList.length,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  setState(() {
                                    if (_title == 'State') {
                                      state.text = _stateSubList[index].name;
                                      _getCity(_stateSubList[index].id);
                                      _stateSubList = _stateList;
                                      city.clear();
                                    } else if (_title == 'City') {
                                      city.text = _citySubList[index].name;
                                      _citySubList = _cityList;
                                    }
                                  });
                                  _controller.clear();
                                  _controller2.clear();
                                  _controller3.clear();
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 20.0, left: 10.0, right: 10.0),
                                  child: Text(
                                      _title == 'State'
                                          ? _stateSubList[index].name
                                          : _citySubList[index].name,
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 16.0)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_title == 'City' && _citySubList.isEmpty) {
                            city.text = _controller3.text;
                          }
                          _stateSubList = _stateList;
                          _citySubList = _cityList;

                          _controller.clear();
                          _controller2.clear();
                          _controller3.clear();
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(0, -1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16.0))));
  }
}
