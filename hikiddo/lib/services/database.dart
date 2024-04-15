import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/models/location.dart';
import 'package:hikiddo/models/profile.dart';
import 'package:hikiddo/models/task.dart';
import 'package:location/location.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection('familyGroup');
  final CollectionReference tasksCollection = FirebaseFirestore.instance.collection('tasks');

  //STREAM
  //Fetch the current users profile data
  Stream<Profile> get currentUserProfile {
    String? uid = FirebaseAuth.instance.currentUser?.uid; // Ensure you have the user's UID
    return userCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }

  //Fetch the avaible tasks for the current family group
  Stream<List<Task>> getFamilyGroupTasks(String familyGroupId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('familyGroupId', isEqualTo: familyGroupId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc.data(), doc.id)).toList());
  }

  //LIST OF METHODS UPDATETING AND FETCHING DATA FROM FIREABASE

  //update user information on profile screen
  Future updateUserData(
      String name, String email, String phoneNumber, String password) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password
    });
  }

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
      // Return a empty Profile if the document doesn't exist
      return Profile(name: '', email: '', phoneNumber: '');
    }
  }

  //Update a specific field in the users collection
  Future<void> safeUpdateUserDataField(String uid, String field, dynamic newValue) async {
    var docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    return await docRef.set({field: newValue}, SetOptions(merge: true));
  }

  //Search for family group
  Future<List<String>> searchGroups(String query) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('familyGroup')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();

    final groupNames = querySnapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    return groupNames;
  }

  //Create new family group and set current user as host
  Future<FamilyGroupCreationResult> createGroup(String groupName) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return FamilyGroupCreationResult(
          success: false, message: 'No user signed in');
    }

    final querySnapshot =
        await groupCollection.where('name', isEqualTo: groupName).get();

    if (querySnapshot.docs.isEmpty) {
      // Create the group and get the reference to the newly created document
      DocumentReference groupDocRef = await groupCollection.add({
        'name': groupName,
        'hostId': currentUid,
        'members': [currentUid],
        'created_at': FieldValue.serverTimestamp(),
      });

      // Use the document reference (groupDocRef) to get the group ID
      String groupId = groupDocRef.id;

      // Update the current user's document with the new group ID
      DocumentReference userRef = userCollection.doc(currentUid);
      await userRef.set({
        'familyGroupId': groupId,
      }, SetOptions(merge: true));

      return FamilyGroupCreationResult(success: true, message: 'Group created successfully');
    } else {
      return FamilyGroupCreationResult(
          success: false, message: 'A group with this name already exists.');
    }
  }

  //Join family group
  Future<void> joinGroup(String groupId) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('No user signed in');

    DocumentReference groupRef = FirebaseFirestore.instance.collection('familyGroup').doc(groupId);

    //Add user to the group's members list
    await groupRef.update({
      'members': FieldValue.arrayUnion([userId]),
    });

    //Add familyGroup ID to users collection
    DocumentReference userRef = userCollection.doc(userId);

    return await userRef.set({
      'familyGroupId': groupId,
    }, SetOptions(merge: true));
  }

    // Method to send a join request
  Future<void> sendJoinRequest(String groupId, String userId) async {
    await _firestore.collection('familyGroup').doc(groupId)
        .collection('joinRequests').doc(userId).set({
      'userId': userId,
      'status': 'pending'
    });
  }

    // Method for the host to approve a join request
  Future<void> approveJoinRequest(String groupId, String userId) async {
    // Move user to the group's member list
    await _firestore.collection('familyGroup').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId])
    });
    // Update the request status to approved
    await _firestore.collection('familyGroup').doc(groupId)
        .collection('joinRequests').doc(userId).update({
      'status': 'approved'
    });

       //Add familyGroup ID to users collection
    DocumentReference userRef = userCollection.doc(userId);

    return await userRef.set({
      'familyGroupId': groupId,
    }, SetOptions(merge: true));
  }

    // Method for the host to deny a join request
  Future<void> denyJoinRequest(String groupId, String userId) async {
    // Update the request status to denied
    await _firestore.collection('familyGroup').doc(groupId)
        .collection('joinRequests').doc(userId).update({
      'status': 'denied'
    });
  }

  //retrived familygroup id using the name of the family group
  // Method to retrieve a group's ID based on its name
  Future<String?> getFamilyGroupIdFromName(
      BuildContext context, String groupName) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('familyGroup')
          .where('name', isEqualTo: groupName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot
            .docs.first.id; // Return the first (and should be only) group ID
      } else {
        return null; // No group found with this name
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error retrieving group ID: $e")),
      );
      return null;
    }
  }

  //retrived familygroupId from users collection
  Future<String?> getFamilyGroupId(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null; // User not logged in

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // Cast the data to a Map<String, dynamic> before using the [] operator
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['familyGroupId'];
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching family group ID: $e")),
      );
      return null;
    }
  }

  //get hostId for from familyGroup
  Future<String?> getFamilyGroupHostId(
      BuildContext context, String familyGroupId) async {
    try {
      DocumentSnapshot groupDoc =
          await groupCollection.doc(familyGroupId).get();
      if (groupDoc.exists) {
        Map<String, dynamic> data = groupDoc.data() as Map<String, dynamic>;
        return data['hostId'] as String?;
      } else {
        return null; // Group not found
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error retrieving family group host ID: $e")),
      );
      return null;
    }
  }

  Future<void> removeMemberFromFamilyGroup(String familyGroupId, String memberUid) async {
    DocumentReference groupRef =_firestore.collection('familyGroup').doc(familyGroupId);
    return await groupRef.update({
      'members': FieldValue.arrayRemove([memberUid])
    }).catchError((error) {
      throw Exception('Failed to remove member: $error');
    });
  }

  // update the task status
  Future<void> taskStatus(String taskId, bool currentStatus) async {
    return tasksCollection.doc(taskId).update({
      'status': !currentStatus,
    });
  }

  // add task
  Future<DocumentReference<Object?>> addTask(
      String familyGroupId, String title, int points) async {
    return await tasksCollection.add({
      'familyGroupId': familyGroupId,
      'title': title,
      'points': points,
      'status': false, // Assuming tasks are not completed by default
    });
  }

  //delete tasks
  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  //update user points after completing a task
  Future<void> updateUserPoints(String userId, int pointsToAdd) async {
    return await userCollection.doc(userId).set({
      'points': FieldValue.increment(pointsToAdd),
    }, SetOptions(merge: true));
  }

// set weekly rewards
  Future<void> setWeeklyReward(String familyGroupId, String title, String description) async {
    await groupCollection.doc(familyGroupId).update({
      'weeklyRewardTitle': title,
      'weeklyRewardDescription': description,
    });
  }

//reset points from family members
  Future<void> resetFamilyGroupPoints(String familyGroupId) async {
    // Fetch all users in the family group
    var snapshot = await userCollection
        .where('familyGroupId', isEqualTo: familyGroupId)
        .get();
    for (var doc in snapshot.docs) {
      // Reset points for each user
      userCollection.doc(doc.id).update({'points': 0});
    }
  }

  // update Latitute and longitude on users collection
  Future<void> updateUserLocation(LocationData locationData) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'lat': locationData.latitude,
        'lng': locationData.longitude,
        'locationUpdateTimestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of user locations for a specific family group
  Stream<List<UserLocation>> getFamilyGroupUserLocationsStream(String familyGroupId) {
    return _firestore
        .collection('users')
        .where('familyGroupId', isEqualTo: familyGroupId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserLocation.fromFirestore(doc))
            .toList());
  }

// Fetch user locations based on family group member IDs
  Future<List<UserLocation>> fetchFamilyGroupUserLocations(
      String familyGroupId, BuildContext context) async {
    try {
      // Use the default return type without forcing a cast here.
      DocumentSnapshot<Object?> familyGroupDoc = await groupCollection.doc(familyGroupId).get();

      if (familyGroupDoc.exists) {
        // Perform a safe cast to Map<String, dynamic> when accessing the data.
        List<dynamic> memberIds = (familyGroupDoc.data() as Map<String, dynamic>)['members'] ?? [];
        List<UserLocation> memberProfiles = [];
        for (var memberId in memberIds) {
          if (memberId is String) {
            DocumentSnapshot<Object?> userDoc =
                await userCollection.doc(memberId).get();
            if (userDoc.exists) {
              // Perform a safe cast to Map<String, dynamic> when passing to fromFirestore.
              UserLocation userProfile = UserLocation.fromFirestore(userDoc as DocumentSnapshot<Map<String, dynamic>>);
              memberProfiles.add(userProfile);
            }
          }
        }
        return memberProfiles;
      } else {
        return []; // Return an empty list if the family group document does not exist.
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Error fetching family group user locations")),);
      }
      return [];
    }
  }
}

class FamilyGroupCreationResult {
  final bool success;
  final String message;

  FamilyGroupCreationResult({required this.success, this.message = ''});
}
