import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

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
}
