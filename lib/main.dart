import 'package:chef_gram_admin/screens/Dashboard/dashboard.dart';
import 'package:chef_gram_admin/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'authentication_service.dart';
import 'database_service.dart';
import 'models/profile_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        Provider<DatabaseService>(
          create: (_) =>
              DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid),
        ),
        StreamProvider(
          create: (context) => context.read<DatabaseService>().profile,
          initialData:
              Profile(name: '', age: 0, role: 'admin'),
        ),
      ],
      child: Sizer(builder: (context, orientation, deviceTye) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Chef Gram",
          theme: ThemeData(
            fontFamily: 'WorkSans',
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
          ),
          darkTheme: ThemeData(
            fontFamily: 'WorkSans',
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.light,
          home: AuthenticationWrapper(),
        );
      }),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser == null) {
      return LogInPage();
    } else {
      return Dashboard();
    }
  }
}
