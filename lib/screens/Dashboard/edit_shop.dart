import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';

class EditShop extends StatefulWidget {
  const EditShop({
    Key? key,
    required this.data,
    required this.id,
  }) : super(key: key);
  final data;
  final String id;

  @override
  _EditShopState createState() => _EditShopState();
}

class _EditShopState extends State<EditShop> {
  void editShop() async {
    try {
      FirebaseFirestore.instance.collection('shops').doc(widget.id).update({
        'address': addressController.text,
        'beat': widget.data['beat'],
        'state': widget.data['state'],
        'city': widget.data['city'],
        'email': emailController.text.isEmpty ? 'none' : emailController.text,
        'phoneNo': phoneNoController.text.isEmpty
            ? '0'
            : (double.parse(phoneNoController.text).toInt()).toString(),
        'shopName': shopNameController.text,
        'shopOwner': shopOwnerController.text,
        'latitude': double.parse(latitudeController.text),
        'longitude': double.parse(longitudeController.text),
        'isLocationMandatory': isSwitched
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Shop data updated"),
        backgroundColor: Colors.blue,
        duration: Duration(milliseconds: 2500),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 2500),
      ));
    }

    Navigator.pop(context);
  }

  late final addressController;
  late final shopNameController;
  late final shopOwnerController;
  late final phoneNoController;
  late final emailController;
  late final latitudeController;
  late final longitudeController;

  @override
  void initState() {
    isSwitched = widget.data['isLocationMandatory'];
    shopNameController = TextEditingController(text: widget.data['shopName']);
    shopOwnerController = TextEditingController(text: widget.data['shopOwner']);
    addressController = TextEditingController(text: widget.data['address']);
    phoneNoController =
        TextEditingController(text: widget.data['phoneNo'].toString());
    emailController = TextEditingController(text: widget.data['email']);
    latitudeController =
        TextEditingController(text: widget.data['latitude'].toString());
    longitudeController =
        TextEditingController(text: widget.data['longitude'].toString());
    super.initState();
  }

  void dispose() {
    addressController.dispose();
    phoneNoController.dispose();
    shopOwnerController.dispose();
    shopNameController.dispose();
    emailController.dispose();
    longitudeController.dispose();
    latitudeController.dispose();

    super.dispose();
  }

  var textValue = 'Location is now Mandatory!';
  late bool isSwitched;
  void toggleSwitch(bool value) {
    if (isSwitched == true) {
      setState(() {
        isSwitched = false;
        textValue = 'Location is now Not Mandatory!';
      });
    } else {
      setState(() {
        isSwitched = true;
        textValue = 'Location is now Mandatory!';
      });
    }
  }

  final formGlobalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Shop"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Column(
            children: [
              SizedBox(
                height: 2.h,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: authTextFieldDecoration.copyWith(
                            labelText: widget.data['state']),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: authTextFieldDecoration.copyWith(
                            labelText: widget.data['city']),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        enabled: false,
                        decoration: authTextFieldDecoration.copyWith(
                            labelText: widget.data['beat']),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: shopOwnerController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Shop Owner",
                          hintText: "Enter Shop Owner",
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: shopNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Shop Name",
                          hintText: "Enter Shop Name",
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: latitudeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Latitude",
                          hintText: "Enter Latitude",
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: longitudeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Longitude",
                          hintText: "Enter Longitude",
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: addressController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Address",
                          hintText: "Enter your Address",
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Shop Email",
                          hintText: "Enter Shop Owner email",
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      TextFormField(
                        controller: phoneNoController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: authTextFieldDecoration.copyWith(
                          labelText: "Phone Number",
                          hintText: "Enter Phone Number",
                        ),
                      ),
                      Row(
                        children: [
                          Switch(
                            onChanged: toggleSwitch,
                            value: isSwitched,
                          ),
                          Text(
                            textValue,
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                child: Text("Edit Shop"),
                onPressed: () {
                  if (formGlobalKey.currentState!.validate()) {
                    formGlobalKey.currentState!.save();
                    editShop();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
