import 'package:chef_gram_admin/utils/RoundedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

import '../../authentication_service.dart';
import '../../constants.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              children: [
                Text(
                  "Spice",
                  style: TextStyle(fontSize: 30.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  decoration: authTextFieldDecoration,
                  controller: nameController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: authTextFieldDecoration.copyWith(
                    labelText: "Password",
                    hintText: "Enter your Password",
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Align(
                  alignment: Alignment.center,
                  child: RoundedButton(
                    color: Color(0xFF004AAD),
                    onPressed: () {
                      context.read<AuthenticationService>().signIn(
                          name: nameController.text.trim(),
                          password: passwordController.text.trim());
                    },
                    text: "LOG IN",
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
