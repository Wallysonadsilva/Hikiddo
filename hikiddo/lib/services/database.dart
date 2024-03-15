import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hikiddo/models/profile.dart';

class DatabaseService {

  final String? uid;
  DatabaseService({ this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection('familyGroup');

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


// search for family group
Future<List<String>> searchGroups(String query) async {
  // Adjust the path ('groups') to match your Firestore structure
  final querySnapshot = await FirebaseFirestore.instance
      .collection('familyGroup')
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThan: '${query}z')
      .get();

  final groupNames = querySnapshot.docs
      .map((doc) => doc.data()['name'] as String)
      .toList();

  return groupNames;
}

// Create new family group and set current user as host
  Future<FamilyGroupCreationResult> createGroup(String groupName) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return FamilyGroupCreationResult(success: false, message: 'No user signed in');
    }

    final querySnapshot = await groupCollection
        .where('name', isEqualTo: groupName)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await groupCollection.add({
        'name': groupName,
        'hostId': currentUid,
        'members': [currentUid],
        'created_at': FieldValue.serverTimestamp(),
      });
      return FamilyGroupCreationResult(success: true, message: 'Group created successfully');
    } else {
      return FamilyGroupCreationResult(success: false, message: 'A group with this name already exists.');
    }
  }

  //join family group
    Future<void> joinGroup(String groupId) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('No user signed in');

    DocumentReference groupRef = FirebaseFirestore.instance.collection('familyGroup').doc(groupId);

    // Add user to the group's members list
    await groupRef.update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  //retrived familygroup id using the name of the family group
  // Method to retrieve a group's ID based on its name
  Future<String?> getFamilyGroupIdFromName(String groupName) async {
    try {
          var querySnapshot = await FirebaseFirestore.instance.collection('familyGroup')
          .where('name', isEqualTo: groupName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Return the first (and should be only) group ID
      } else {
        return null; // No group found with this name
      }
    } catch (e) {
      print("Error retrieving group ID: $e");
      return null;
    }
  }


}


class FamilyGroupCreationResult {
  final bool success;
  final String message;

  FamilyGroupCreationResult({required this.success, this.message = ''});
}