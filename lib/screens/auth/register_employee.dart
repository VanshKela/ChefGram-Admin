import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chef_gram_admin/utils/RoundedButton.dart';
import '../../constants.dart';
import '../../database_service.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({Key? key}) : super(key: key);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNoController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  late UserCredential userCredential;
  String role = "employee";

  Future<void> addUser() async {
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: "${phoneNoController.text.trim()}@spice.com",
              password: passwordController.value.text);
    } on FirebaseAuthException catch (e) {
      final snackBar = SnackBar(
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 8),
        content: Text(
          e.message.toString(),
          style: TextStyle(color: Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (role == 'employee') {
      return users.doc(userCredential.user!.uid).set({
        'name': nameController.value.text,
        'role': role,
        'phoneNo': phoneNoController.text,
        'age': int.parse(ageController.value.text),
        'monthlyTarget': 0,
        'targetData': {'todayTarget': 0},
        'timeTargetUpdated': DateTime.now().subtract(Duration(days: 1)),
      }).then((value) {
        passwordController.clear();
        nameController.clear();
        ageController.clear();
        phoneNoController.clear();
        final snackBar = SnackBar(
          backgroundColor: Colors.lightBlue,
          duration: Duration(seconds: 8),
          content: Text(
            "Success! New User Created!",
            style: TextStyle(color: Colors.white),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Provider.of<DatabaseService>(context, listen: false).getEmployeeData();
      }).catchError((error) {
        final snackBar = SnackBar(
          backgroundColor: Colors.lightBlue,
          duration: Duration(seconds: 8),
          content: Text(
            error,
            style: TextStyle(color: Colors.white),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else
    return users.doc(userCredential.user!.uid).set({
      'name': nameController.value.text,
      'role': role,
      'phoneNo': phoneNoController.text,
      'age': int.parse(ageController.value.text),
    }).then((value) {
      passwordController.clear();
      nameController.clear();
      ageController.clear();
      phoneNoController.clear();
      final snackBar = SnackBar(
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 8),
        content: Text(
          "Success! New User Created!",
          style: TextStyle(color: Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).catchError((error) {
      final snackBar = SnackBar(
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 8),
        content: Text(
          error,
          style: TextStyle(color: Colors.white),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    ageController.dispose();
    phoneNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add User"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              children: [
                Text(
                  "Add New User",
                  style: TextStyle(fontSize: 30.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Name",
                    hintText: "Enter Full Name",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: phoneNoController,
                  maxLength: 10,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Phone Number",
                    hintText: "Enter your phone number",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: passwordController,
                  textAlign: TextAlign.center,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Password",
                    hintText: "Enter new Password",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: ageController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Age",
                    hintText: "Enter Age",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Select Role:",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: DropdownButton<String>(
                          icon: const Icon(Icons.arrow_drop_down),
                          hint: Text(role),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.blueGrey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              role = newValue!;
                            });
                          },
                          items: <String>[
                            'employee',
                            'admin',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RoundedButton(
                    color: Color(0xFF004AAD),
                    onPressed: addUser,
                    text: "Add Employee",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
