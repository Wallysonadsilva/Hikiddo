import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hikiddo/models/profile.dart';

class DatabaseService {

  final String? uid;
  DatabaseService({ this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name) async {
    return await userCollection.doc(uid).set({
      'name': name
    });
  }

  // user profile
  List<Profile> _profileListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc) {
      // Call .data() as a method and cast the result to Map<String, dynamic>
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Profile(
        name: data['name'] ?? '', // Use the 'name' key to access the name property
      );
    }).toList();
  }

  //get user stream
  Stream<List<Profile>> get users{
    return userCollection.snapshots()
      .map(_profileListFromSnapshot);
  }

}