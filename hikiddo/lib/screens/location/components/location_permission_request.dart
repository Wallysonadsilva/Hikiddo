import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<void> requestPermission() async {
    final bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      await location.requestService();
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception("Location permission not granted");
      }
    }
  }

  Stream<LocationData> get locationStream => location.onLocationChanged;

}
