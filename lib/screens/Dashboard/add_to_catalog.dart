import 'dart:typed_data';
import 'package:chef_gram_admin/utils/RoundedButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../constants.dart';
import 'package:file_picker/file_picker.dart';

class AddToCatalog extends StatefulWidget {
  const AddToCatalog({Key? key}) : super(key: key);

  @override
  _AddToCatalogState createState() => _AddToCatalogState();
}

class _AddToCatalogState extends State<AddToCatalog> {
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final nameController = TextEditingController();
  CollectionReference catalog =
      FirebaseFirestore.instance.collection('catalog');
  FilePickerResult? result;
  Future selectFile() async {
    result = await FilePicker.platform.pickFiles(withData: true);
  }

  Future addToCatalog() async {
    if (result != null) {
      Uint8List? fileBytes = result!.files.first.bytes;
      String fileName = result!.files.first.name;
      // Upload file
      await FirebaseStorage.instance
          .ref('catalog/$fileName')
          .putData(fileBytes!);
      String imageLink = await FirebaseStorage.instance
          .ref('catalog/$fileName')
          .getDownloadURL();
      print(imageLink);

      return catalog.doc(fileName).set({
        'name': nameController.value.text,
        'quantity': int.parse(quantityController.value.text),
        'price': int.parse(priceController.value.text),
        'image': imageLink
      }).then((value) {
        priceController.clear();
        nameController.clear();
        quantityController.clear();
        result = null;
      });
    }
    Navigator.pop(context);
  }

  void dispose() {
    priceController.dispose();
    quantityController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add To Catalog"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              children: [
                Text(
                  "Add Items to Catalog",
                  style: TextStyle(fontSize: 30.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  decoration: authTextFieldDecoration.copyWith(
                      labelText: 'Name', hintText: 'Pav Bhaji Masala'),
                  controller: nameController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: priceController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Price",
                    hintText: "Enter amount in Rupees",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Quantity",
                    hintText: "Enter quantity in grams",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                ElevatedButton(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Icon(Icons.file_upload), Text('Select File')],
                  ),
                  onPressed: selectFile,
                ),
                SizedBox(
                  height: 2.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RoundedButton(
                    color: Color(0xFF004AAD),
                    onPressed: addToCatalog,
                    text: "Add To Cart",
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
