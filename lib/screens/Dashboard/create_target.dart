import 'package:chef_gram_admin/utils/RoundedButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import 'employee_list.dart';

class CreateTarget extends StatefulWidget {
  CreateTarget({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<CreateTarget> createState() => _CreateTargetState();
}

class _CreateTargetState extends State<CreateTarget> {
  final monthlyTargetController = TextEditingController();

  CollectionReference collection =
      FirebaseFirestore.instance.collection('users');

  var document;

  Future<void> setTarget() async {
    var targetData = {
      'monthlyTarget': int.parse(monthlyTargetController.value.text),
    };
    await document.update(targetData);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ShowEmployees()));
  }

  void getInfo() async {
    document = await collection.doc(widget.id);
    var docSnapshot = await document.get();
    monthlyTargetController.text = "${docSnapshot.get('monthlyTarget')}";
  }

  @override
  initState() {
    getInfo();
    super.initState();
  }

  @override
  void dispose() {
    monthlyTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create Employee Target"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Container(
            child: Column(
              children: [
                TextFormField(
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Monthly Target",
                    hintText: "Enter Monthly Target",
                  ),
                  controller: monthlyTargetController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 4.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RoundedButton(
                    color: Colors.blue,
                    onPressed: () {
                      setTarget();
                    },
                    text: "Set Target",
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
