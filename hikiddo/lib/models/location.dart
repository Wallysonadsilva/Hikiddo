import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final String profileImageUrl;

  UserLocation({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.profileImageUrl,
  });

  factory UserLocation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    double latitude = data['lat']?.toDouble() ?? 0.0;
    double longitude = data['lng']?.toDouble() ?? 0.0;
    String name = data['name'] ?? 'No Name';
    // Use a default URL if no URL is found
    String profileImageUrl = data['imageLink'] as String? ?? 'https://t3.ftcdn.net/jpg/02/09/37/00/360_F_209370065_JLXhrc5inEmGl52SyvSPeVB23hB6IjrR.jpg';

    return UserLocation(
      userId: doc.id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      profileImageUrl: profileImageUrl,
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}
