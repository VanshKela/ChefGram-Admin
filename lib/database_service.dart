import 'package:cloud_firestore/cloud_firestore.dart';

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
    print("hello");
    print(snapshot.data());
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
          "image": data["image"]
        });
      }
      return catalog;
    } else
      return catalog;
  }
}
