import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final String userId;
  final String name; // Add name field
  final double latitude;
  final double longitude;

  UserLocation({
    required this.userId, 
    required this.name, // Initialize name field
    required this.latitude, 
    required this.longitude
  });

  factory UserLocation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    double latitude = data['lat']?.toDouble() ?? 0.0;
    double longitude = data['lng']?.toDouble() ?? 0.0;
    String name = data['name'] ?? 'No Name'; // Assume there's a 'name' field in your document

    return UserLocation(
      userId: doc.id,
      name: name, // Set the name field
      latitude: latitude,
      longitude: longitude,
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}



