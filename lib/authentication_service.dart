import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn(
      {required String number, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: "$number@spice.com", password: password);
      await FirebaseFirestore.instance.collection("users")
          .doc(_firebaseAuth.currentUser!.uid).get()
          .then((value) {
        print(value.exists);
        print(value.data());
        if(value.get('role') == 'admin'){
        } else {
          signOut();
        }
        return value;
      });
      return "Signed In Successfully";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "error";
    }
  }
}
