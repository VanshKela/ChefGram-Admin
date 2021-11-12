import 'package:chef_gram_admin/models/profile_model.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../../authentication_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    if (Provider.of<Profile>(context).role == "employee")
      return NotAnAdmin();
    else
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            IconButton(
                onPressed: () {
                  Provider.of<AuthenticationService>(context, listen: false)
                      .signOut();
                },
                icon: Icon(Icons.logout)),
          ],
        ),
        body: Center(
          child: Text('hello'),
        ),
      );
  }
}

class NotAnAdmin extends StatelessWidget {
  const NotAnAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<AuthenticationService>(context, listen: false)
                    .signOut();
              },
              icon: Icon(Icons.logout)),
        ],
        title: Text("Unauthorised Access"),
      ),
      body: Center(
        child: Text("Not an employee"),
      ),
    );
  }
}
