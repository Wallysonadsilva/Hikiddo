import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({required this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name) async {
    return await userCollection.doc(uid).set({
      'name': name
    });
  }

}