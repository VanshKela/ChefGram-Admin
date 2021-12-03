import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';

class EditEmployee extends StatefulWidget {
  const EditEmployee({Key? key, required this.id, required this.data})
      : super(key: key);
  final String id;
  final data;
  @override
  _EditEmployeeState createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  late final ageController;
  late final monthlyTargetController;
  late final nameController;
  late final phoneNoController;

  @override
  void deleteUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .update({'isActive': false}).then((value) {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 2500),
      ));
    }
  }

  void updateUserData() async {
    Loader.show(context);
    try {
      var document =
          FirebaseFirestore.instance.collection('users').doc(widget.id);
      var targetData = {
        'monthlyTarget':
            double.parse(monthlyTargetController.value.text).toInt(),
        'name': nameController.value.text,
        'phoneNo': double.parse(phoneNoController.value.text).toInt(),
        'age': double.parse(ageController.value.text).toInt()
      };
      await document.update(targetData).then((value) => Loader.hide());
    } catch (e) {
      Loader.hide();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 2500),
      ));
    }
    Loader.hide();
    Navigator.pop(context);
  }

  void initState() {
    phoneNoController =
        TextEditingController(text: widget.data['phoneNo'].toString());
    ageController = TextEditingController(text: widget.data['age'].toString());
    nameController = TextEditingController(text: widget.data['name']);
    monthlyTargetController =
        TextEditingController(text: widget.data['monthlyTarget'].toString());
    super.initState();
  }

  @override
  void dispose() {
    ageController.dispose();
    nameController.dispose();
    phoneNoController.dispose();
    monthlyTargetController.dispose();
    Loader.hide();
    super.dispose();
  }

  final formGlobalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Employee Data"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formGlobalKey,
          child: Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Name",
                  hintText: "Enter User Name",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: monthlyTargetController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Monthly Target",
                  hintText: "Enter Monthly target",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Age",
                  hintText: "Enter age",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              TextFormField(
                controller: phoneNoController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                decoration: authTextFieldDecoration.copyWith(
                  labelText: "Phone Number",
                  hintText: "Enter Phone Number",
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    child: Text("Delete User"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red.shade400),
                    ),
                    onPressed: () {
                      if (formGlobalKey.currentState!.validate()) {
                        formGlobalKey.currentState!.save();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Warning",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        "This will delete this user permanently.Past orders and data will still remain accessible to admin!!",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      "This action cannot be undone!",
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    deleteUser();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Text("Update User"),
                    onPressed: () {
                      if (formGlobalKey.currentState!.validate()) {
                        formGlobalKey.currentState!.save();
                        updateUserData();
                      }
                    },
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
