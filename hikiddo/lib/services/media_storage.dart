import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hikiddo/models/mediatype.dart';
import 'package:hikiddo/models/voice_recording.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MediaDataServices {
  Future<String> uploadMediaToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> savaData({required Uint8List file}) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      String imageUrl = await uploadMediaToStorage(
          "profileImages/$userId", file); // Ensure unique path for each user
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'imageLink': imageUrl,
        });
        return "success"; // Ensure this line is reached after successful upload and update
      } else {
        return "User ID is null"; // More specific error message
      }
    } catch (err) {
      return err.toString(); // Consider logging this error as well
    }
  }

  Future<String?> loadUserProfilePic() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final data = userDoc.data() as Map<String, dynamic>?;
      if (userDoc.exists && data != null && data.containsKey('imageLink')) {
        return data['imageLink'];
      }
    }
    return null;
  }

Future<String> uploadMemoryBoardMedia(Uint8List fileBytes, String fileName, String groupId, bool isVideo) async {
  String filePath = 'memoryBoard/${isVideo ? 'Videos' : 'Images'}/$groupId/$fileName';
  Reference ref = _storage.ref().child(filePath);
  UploadTask uploadTask = ref.putData(fileBytes);
  TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
  String downloadUrl = await snapshot.ref.getDownloadURL();

  await FirebaseFirestore.instance.collection('memoryBoardMedia').add({
    'mediaUrl': downloadUrl,
    'familyGroupId': groupId,
    'isVideo': isVideo,
    'timestamp': FieldValue.serverTimestamp(),
  });

  return downloadUrl;
}



 Future<List<MediaItem>> fetchMemoryBoardMedia(String groupId) async {
  List<MediaItem> mediaItems = [];

  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('memoryBoardMedia')
      .where('familyGroupId', isEqualTo: groupId)
      .get();

  for (var doc in snapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    mediaItems.add(MediaItem(url: data['mediaUrl'], isVideo: data['isVideo']));
  }

  return mediaItems;
}

//record
  Future<List<VoiceRecording>> fetchRecordings(String groupId) async {
    final querySnapshot = await _firestore
        .collection('recordings')
        .where('familyGroupId', isEqualTo: groupId)
        .get();

    return querySnapshot.docs
        .map((doc) => VoiceRecording.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> deleteRecording(String recordingId, String fileUrl) async {
    // Delete the file from Firebase Storage
    await FirebaseStorage.instance.refFromURL(fileUrl).delete();
    // Delete the document from Firestore
    await _firestore.collection('recordings').doc(recordingId).delete();
  }

Future<String> saveRecording(Uint8List recordingData, String title, String groupId) async {
  // Assuming recordingData is the binary data of your recording
  // Save the recording to Firebase Storage first
  String filePath = 'recordings/$groupId/${DateTime.now().millisecondsSinceEpoch}.mp3';
  Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
  UploadTask uploadTask = storageRef.putData(recordingData);
  await uploadTask.whenComplete(() => null);
  String fileUrl = await storageRef.getDownloadURL();

  // Get current user's ID
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception("User not logged in");

  // Save recording metadata to Firestore, including the user ID
  DocumentReference docRef = await _firestore.collection('recordings').add({
    'title': title,
    'date': Timestamp.now(),
    'fileUrl': fileUrl,
    'familyGroupId': groupId,
    'userId': userId, // Add the user ID here
  });

  return docRef.id; // Optionally return document ID
}


  Future<void> updateRecordingTitle(String recordingId, String newTitle) async {
  await _firestore.collection('recordings').doc(recordingId).update({'title': newTitle});
}


}
