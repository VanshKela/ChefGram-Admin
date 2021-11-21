import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';

class AddShopToBeat extends StatefulWidget {
  const AddShopToBeat({
    Key? key,
    required this.state,
    required this.city,
    required this.beat,
  }) : super(key: key);
  final String state;
  final String city;
  final String beat;

  @override
  _AddShopToBeatState createState() => _AddShopToBeatState();
}

class _AddShopToBeatState extends State<AddShopToBeat> {
  void addShopToBeat() async {
    try {
      FirebaseFirestore.instance.collection('shops').add({
        'address': addressController.text,
        'beat': widget.beat,
        'state': widget.state,
        'city': widget.city,
        'email': emailController.text,
        'phoneNo': phoneNoController.text,
        'shopName': shopNameController.text,
        'shopOwner': shopOwnerController.text
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Shop Added"),
        backgroundColor: Colors.blue,
        duration: Duration(milliseconds: 1600),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.blue,
        duration: Duration(milliseconds: 600),
      ));
    }
  }

  final addressController = TextEditingController();
  final shopNameController = TextEditingController();
  final shopOwnerController = TextEditingController();
  final phoneNoController = TextEditingController();
  final emailController = TextEditingController();
  void dispose() {
    addressController.dispose();
    phoneNoController.dispose();
    shopOwnerController.dispose();
    shopNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Shops"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                          labelText: widget.state),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      enabled: false,
                      decoration: authTextFieldDecoration.copyWith(
                          labelText: widget.city),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      enabled: false,
                      decoration: authTextFieldDecoration.copyWith(
                          labelText: widget.beat),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      controller: shopNameController,
                      decoration: authTextFieldDecoration.copyWith(
                        labelText: "Shop Owner",
                        hintText: "Enter Shop Owner",
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      controller: shopOwnerController,
                      decoration: authTextFieldDecoration.copyWith(
                        labelText: "Shop Name",
                        hintText: "Enter Shop Name",
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    TextFormField(
                      controller: addressController,
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
                    SizedBox(
                      height: 2.h,
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              child: Text("Add Shop"),
              onPressed: () {
                addShopToBeat();
                addressController.clear();
                phoneNoController.clear();
                shopOwnerController.clear();
                shopNameController.clear();
                emailController.clear();
              },
            )
          ],
        ),
      ),
    );
  }
}
