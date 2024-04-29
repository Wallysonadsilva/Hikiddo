import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/models/location.dart';
import 'package:hikiddo/models/profile.dart';
import 'package:hikiddo/models/task.dart';
import 'package:location/location.dart';

class DatabaseService {
  final String? uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference userCollection;
  final CollectionReference groupCollection;
  final CollectionReference tasksCollection;

  DatabaseService({this.uid})
      : userCollection = FirebaseFirestore.instance.collection('users'),
        groupCollection = FirebaseFirestore.instance.collection('familyGroup'),
        tasksCollection = FirebaseFirestore.instance.collection('tasks');

  // Fetch the current user's profile data
  Stream<Profile> get currentUserProfile {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return userCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }

  // Fetch the available tasks for the current family group
 Stream<List<Task>> getFamilyGroupTasks(String familyGroupId) {
  return tasksCollection
      .where('familyGroupId', isEqualTo: familyGroupId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList());
}

  Future<void> updateUserData(String name, String email, String phoneNumber) async {
    await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    });
  }

  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      return Profile(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
      );
    } else {
      return Profile(name: '', email: '', phoneNumber: '');
    }
  }

  Future<void> safeUpdateUserDataField(String uid, String field, dynamic newValue) async {
    await userCollection.doc(uid).set({field: newValue}, SetOptions(merge: true));
  }

Future<List<String>> searchGroups(String query) async {
  var querySnapshot = await groupCollection
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThan: '${query}z')
      .get();

  // Cast each document data to Map<String, dynamic>
  return querySnapshot.docs
      .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String?)
      .where((name) => name != null)
      .map((name) => name!)
      .toList();
}

  Future<FamilyGroupCreationResult> createGroup(String groupName) async {
    var currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return FamilyGroupCreationResult(success: false, message: 'No user signed in');
    }
    var querySnapshot = await groupCollection.where('name', isEqualTo: groupName).get();
    if (querySnapshot.docs.isEmpty) {
      var groupDocRef = await groupCollection.add({
        'name': groupName,
        'hostId': currentUid,
        'members': [currentUid],
        'created_at': FieldValue.serverTimestamp(),
      });
      var groupId = groupDocRef.id;
      await userCollection.doc(currentUid).set({'familyGroupId': groupId}, SetOptions(merge: true));
      return FamilyGroupCreationResult(success: true, message: 'Group created successfully');
    } else {
      return FamilyGroupCreationResult(success: false, message: 'A group with this name already exists.');
    }
  }

  Future<void> joinGroup(String groupId) async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('No user signed in');
    var groupRef = groupCollection.doc(groupId);
    await groupRef.update({'members': FieldValue.arrayUnion([userId])});
    await userCollection.doc(userId).set({'familyGroupId': groupId}, SetOptions(merge: true));
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
    var batch = _firestore.batch();
    var groupRef = _firestore.collection('familyGroup').doc(groupId);
    batch.update(groupRef, {
      'members': FieldValue.arrayUnion([userId])
    });
    var joinRequestRef = groupRef.collection('joinRequests').doc(userId);
    batch.update(joinRequestRef, {
      'status': 'approved'
    });
    var userRef = userCollection.doc(userId);
    batch.set(userRef, {
      'familyGroupId': groupId,
    }, SetOptions(merge: true));
    await batch.commit();
  }

  // Method for the host to deny a join request
  Future<void> denyJoinRequest(String groupId, String userId) async {
    var joinRequestRef = _firestore.collection('familyGroup').doc(groupId)
        .collection('joinRequests').doc(userId);
    await joinRequestRef.update({
      'status': 'denied'
    });
  }

  // Retrieve a group's ID based on its name
  Future<String?> getFamilyGroupIdFromName(BuildContext context, String groupName) async {
    try {
      var querySnapshot = await groupCollection.where('name', isEqualTo: groupName).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error retrieving group ID: $e")));
      return null;
    }
  }

  // Retrieve family group ID from user's collection
  Future<String?> getFamilyGroupId(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      DocumentSnapshot userDoc = await userCollection.doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['familyGroupId'];
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching family group ID: $e")));
      return null;
    }
  }

  // Get host ID from family group
  Future<String?> getFamilyGroupHostId(BuildContext context, String familyGroupId) async {
    try {
      DocumentSnapshot groupDoc = await groupCollection.doc(familyGroupId).get();
      if (groupDoc.exists) {
        Map<String, dynamic> data = groupDoc.data() as Map<String, dynamic>;
        return data['hostId'];
      } else {
        return null;
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error retrieving family group host ID: $e")));
      return null;
    }
  }

  // Remove a member from a family group
  Future<void> removeMemberFromFamilyGroup(String familyGroupId, String memberUid) async {
    try {
      DocumentReference groupRef = groupCollection.doc(familyGroupId);
      await groupRef.update({
        'members': FieldValue.arrayRemove([memberUid])
      });
    } catch (error) {
      throw Exception('Failed to remove member: $error');
    }
  }

  // Update task status
  Future<void> taskStatus(String taskId, bool currentStatus) async {
    await tasksCollection.doc(taskId).update({
      'status': !currentStatus,
    });
  }

  // Add a task to the tasks collection
  Future<DocumentReference<Object?>> addTask(String familyGroupId, String title, int points) async {
    return await tasksCollection.add({
      'familyGroupId': familyGroupId,
      'title': title,
      'points': points,
      'status': false
    });
  }

  // Delete a task from the tasks collection
  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  // Update user points after completing a task
  Future<void> updateUserPoints(String userId, int pointsToAdd) async {
    await userCollection.doc(userId).set({
      'points': FieldValue.increment(pointsToAdd),
    }, SetOptions(merge: true));
  }

// Set weekly rewards for a family group
  Future<void> setWeeklyReward(String familyGroupId, String title, String description) async {
    await groupCollection.doc(familyGroupId).update({
      'weeklyRewardTitle': title,
      'weeklyRewardDescription': description,
    });
  }

// Reset points for all members of a family group
  Future<void> resetFamilyGroupPoints(String familyGroupId) async {
    var snapshot = await userCollection.where('familyGroupId', isEqualTo: familyGroupId).get();
    for (var doc in snapshot.docs) {
      userCollection.doc(doc.id).update({'points': 0});
    }
  }

  // Update latitude and longitude in the users collection
  Future<void> updateUserLocation(LocationData locationData) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await userCollection.doc(userId).update({
        'lat': locationData.latitude,
        'lng': locationData.longitude,
        'locationUpdateTimestamp': FieldValue.serverTimestamp(),
      });
    }
  }


  // Stream of user locations for a specific family group
 Stream<List<UserLocation>> getFamilyGroupUserLocationsStream(String familyGroupId) {
  return _firestore
      .collection('users')
      .where('familyGroupId', isEqualTo: familyGroupId)
      .snapshots()
      .map((snapshot) {
        try {
          return snapshot.docs
              .map((doc) => UserLocation.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))  // Cast DocumentSnapshot to the expected generic type
              .toList();
        } catch (e) {
          rethrow;
        }
      });
}



// Fetch user locations based on family group member IDs
  Future<List<UserLocation>> fetchFamilyGroupUserLocations(String familyGroupId, BuildContext context) async {
    try {
      DocumentSnapshot<Object?> familyGroupDoc = await groupCollection.doc(familyGroupId).get();
      if (familyGroupDoc.exists) {
        List<dynamic> memberIds = (familyGroupDoc.data() as Map<String, dynamic>)['members'] ?? [];
        List<UserLocation> memberProfiles = [];
        for (var memberId in memberIds) {
          if (memberId is String) {
            DocumentSnapshot<Object?> userDoc = await userCollection.doc(memberId).get();
            if (userDoc.exists) {
              UserLocation userProfile = UserLocation.fromFirestore(userDoc.data() as DocumentSnapshot<Map<String, dynamic>>);
              memberProfiles.add(userProfile);
            }
          }
        }
        return memberProfiles;
      } else {
        return []; // Return an empty list if the family group document does not exist.
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching family group user locations: $e")));
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
