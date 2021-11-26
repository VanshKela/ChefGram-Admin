import 'package:chef_gram_admin/utils/RoundedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import '../../authentication_service.dart';
import '../../constants.dart';
import '../../main.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final phoneNoController = TextEditingController();
  final passwordController = TextEditingController();

  final formGlobalKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneNoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 100.h,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'images/chef.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 40.h),
                child: Form(
                  key: formGlobalKey,
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
                      child: Column(
                        children: [
                          Text(
                            "Log in to Chef Gram",
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              return null;
                            },
                            maxLength: 10,
                            decoration: authTextFieldDecoration.copyWith(
                              fillColor: (Colors.white),
                              filled: true,
                            ),
                            controller: phoneNoController,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 4.h,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                            controller: passwordController,
                            obscureText: true,
                            decoration: authTextFieldDecoration.copyWith(
                              fillColor: (Colors.white),
                              filled: true,
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
                              onPressed: () async {
                                if (formGlobalKey.currentState!.validate()) {
                                  formGlobalKey.currentState!.save();

                                  await context
                                      .read<AuthenticationService>()
                                      .signIn(
                                          number: phoneNoController.text.trim(),
                                          password:
                                              passwordController.text.trim())
                                      .then((value) {
                                    if (value == 'Signed In Successfully') {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyApp()));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(value),
                                        backgroundColor: Colors.red,
                                        duration: Duration(milliseconds: 4000),
                                      ));
                                    }
                                  });
                                }
                              },
                              text: "LOG IN",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
