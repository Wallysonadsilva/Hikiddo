import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hikiddo/models/profile.dart';

class DatabaseService {

  final String? uid;
  DatabaseService({ this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String email, String phoneNumber, String password) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password
    });
  }

  // fetch user profile info
  //List<Profile> _profileListFromSnapshot(QuerySnapshot snapshot){
    //return snapshot.docs.map((doc) {
      // Call .data() as a method and cast the result to Map<String, dynamic>
      //Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      //return Profile(
        //name: data['name'] ?? '',
        //email: data['email'] ?? '',
        //phoneNumber: data['phoneNumber'] ?? '' // Use the 'name' key to access the name property
      //);
    //}).toList();
  //}

  // Convert DocumentSnapshot into a Profile object
Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
  if (snapshot.exists) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Profile(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  } else {
    // Return a default or empty Profile if the document doesn't exist
    // Adjust according to how you want to handle non-existent user data
    return Profile(name: '', email: '', phoneNumber: '');
  }
}


    // Method to update a specific field for thse user
  Future<void> safeUpdateUserDataField(String uid, String field, dynamic newValue) async {
  var docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  return await docRef.set({ field: newValue }, SetOptions(merge: true));
}

  //get user stream
  //Stream<List<Profile>> get users{
    //return userCollection.snapshots()
      //.map(_profileListFromSnapshot);
  //}
// Stream to fetch the current user's profile data
Stream<Profile> get currentUserProfile {
  String? uid = FirebaseAuth.instance.currentUser?.uid; // Ensure you have the user's UID
  return userCollection.doc(uid).snapshots().map(_profileFromSnapshot);
}


}