import 'dart:io';
import 'dart:typed_data';
import 'package:chef_gram_admin/utils/RoundedButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constants.dart';
import '../../database_service.dart';

class EditCatalogItem extends StatefulWidget {
  const EditCatalogItem({Key? key, required this.data}) : super(key: key);
  final Map data;

  @override
  _EditCatalogItemState createState() => _EditCatalogItemState();
}

class _EditCatalogItemState extends State<EditCatalogItem> {
  final formGlobalKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? image = null;
  Uint8List? fileBytes;
  late final priceController;
  late final quantityController;
  late final nameController;
  CollectionReference catalog =
      FirebaseFirestore.instance.collection('catalog');
  Future selectFile() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = pickedFile;
    });
  }

  Future addToCatalog() async {
    if (image != null) {
      fileBytes = await image!.readAsBytes();
      String fileName = image!.name;
      // Upload file
      await FirebaseStorage.instance
          .ref('catalog/$fileName')
          .putData(fileBytes!);
      String imageLink = await FirebaseStorage.instance
          .ref('catalog/$fileName')
          .getDownloadURL();

      return catalog.doc(widget.data['id'].toString()).update({
        'name': nameController.value.text,
        'quantity': double.parse(quantityController.value.text).toInt(),
        'price': double.parse(priceController.value.text).toInt(),
        'image': imageLink
      }).then((value) {
        priceController.clear();
        nameController.clear();
        quantityController.clear();
        image = null;
      });
    } else {
      return catalog.doc(widget.data['id'].toString()).update({
        'name': nameController.value.text,
        'quantity': int.parse(quantityController.value.text),
        'price': int.parse(priceController.value.text),
      }).then((value) {
        priceController.clear();
        nameController.clear();
        quantityController.clear();
        Loader.hide();
      });
    }
  }

  @override
  void initState() {
    print(widget.data);
    nameController = TextEditingController(text: widget.data['name']);
    priceController =
        TextEditingController(text: widget.data['price'].toString());
    quantityController =
        TextEditingController(text: widget.data['quantity'].toString());
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Item"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Form(
              key: formGlobalKey,
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
                        labelText: 'Name', hintText: 'Enter masala name'),
                    controller: nameController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextFormField(
                    controller: quantityController,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter quantity';
                      }
                      return null;
                    },
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
                  Container(
                    height: (image == null) ? 5.h : 30.h,
                    width: 30.h,
                    child: (image == null)
                        ? Image.network(widget.data['image'])
                        : Image.file(File(image!.path)),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RoundedButton(
                      color: Color(0xFF004AAD),
                      onPressed: () {
                        if (formGlobalKey.currentState!.validate() &&
                            (image != null)) {
                          formGlobalKey.currentState!.save();
                          Loader.show(context);
                          addToCatalog();
                          Navigator.pop(context, true);
                        }
                      },
                      text: "Edit",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
