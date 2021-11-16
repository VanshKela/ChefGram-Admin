import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'models/profile_model.dart';

class DatabaseService {
  final String uid;

  DatabaseService({
    required this.uid,
  });

  static CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<Profile> get profile {
    return _profileCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }


  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    return Profile(
      name: snapshot.get('name') ?? '',
      age: snapshot.get('age') ?? 0,
      role: snapshot.get('role') ?? '',
    );
  }

  List catalog = [];

  Future<List> getCatalog() async {
    if (catalog.isEmpty) {
      var collection = FirebaseFirestore.instance.collection('catalog');
      var querySnapshot = await collection.get();
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        catalog.add({
          "name": data["name"],
          "price": data["price"],
          "quantity": data["quantity"],
          "image": data["image"],
          'id': queryDocumentSnapshot.id
        });
      }
      return catalog;
    } else
      return catalog;
  }

  Filters filters = Filters();
}

class Filters extends ChangeNotifier {
  var state;
  var city;
  var beat;
  var employee;
  var startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(Duration(days: 6));
  var endDate = DateTime.now();
  Stream<QuerySnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
      .instance
      .collection('orders')
      .where('dateTime',
          isGreaterThan: DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(Duration(days: 6)),
          isLessThanOrEqualTo: DateTime.now())
      .orderBy('dateTime', descending: true)
      .snapshots();

  Filters({
    this.state,
    this.city,
    this.beat,
    this.employee,
  });

  void reset() {
    this.state = null;
    this.city = null;
    this.beat = null;
    this.employee = null;
    this.startDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .subtract(Duration(days: 6));
    this.endDate = DateTime.now();
  }

  void update({state, city, beat, employee}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('orders')
        .where('dateTime',
            isGreaterThan: this.startDate, isLessThanOrEqualTo: this.endDate)
        .orderBy('dateTime', descending: true);
    this.state = state;
    this.city = city;
    this.employee = employee;
    this.beat = beat;
    if (employee != null) query = query.where('orderTakenBy', isEqualTo: employee);
    if (state != null) query = query.where('state', isEqualTo: state);
    if (city != null) query = query.where('city', isEqualTo: city);
    if (beat != null) query = query.where('beat', isEqualTo: beat);
    this.stream = query.snapshots();
    notifyListeners();
  }
}
