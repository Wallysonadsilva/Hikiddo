import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hikiddo/models/location.dart'; // Ensure this file reflects the updated UserLocation class
import 'package:hikiddo/screens/location/components/custom_marker.dart';
import 'package:hikiddo/services/database.dart';
import 'package:location/location.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final DatabaseService _databaseService = DatabaseService();
  final Location location = Location();
  Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<List<UserLocation>>? _locationUpdatesSubscription;
  bool _initialFitDone = false;
  late BitmapDescriptor customIcon;

 @override
  void initState() {
    super.initState();
    _requestPermission();
    _listenLocationChanges();
    _setupFamilyGroupMarkers();
  }

  @override
  void dispose() {
    _locationUpdatesSubscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  Future<void> _setupFamilyGroupMarkers() async {
    String? familyGroupId = await _databaseService.getFamilyGroupId(context);
    if (familyGroupId != null) {
      _listenForLocationUpdates(familyGroupId);
    } else {
      print("No family group ID found or user not part of a family group.");
    }
  }

  void _listenForLocationUpdates(String familyGroupId) {
    _locationUpdatesSubscription?.cancel(); // Cancel any existing subscription first
    _locationUpdatesSubscription = _databaseService
        .getFamilyGroupUserLocationsStream(familyGroupId)
        .listen(
      (locations) async {
        await _updateMarkers(locations);
      },
      onError: (error) => print("Error listening to location updates: $error"),
    );
  }


  Future<void> _updateMarkers(List<UserLocation> locations) async {
    Set<Marker> newMarkers = {};
    for (var userLocation in locations) {
      final BitmapDescriptor icon = await getMarkerIcon('assets/images/login_center.png', Size(150, 150));// Adjust the path and size as needed
      final marker = Marker(
        markerId: MarkerId(userLocation.userId),
        position: userLocation.latLng,
        icon: icon, // Use the custom icon
        infoWindow: InfoWindow(title: userLocation.name),
        onTap: _fitMarkers
      );

      newMarkers.add(marker);
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  Future<void> _fitMarkers() async {
    if (_markers.isNotEmpty && _controller.isCompleted && !_initialFitDone) {
      var controller = await _controller.future;
      var bounds = _getLatLngBounds(_markers);
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      controller.animateCamera(cameraUpdate);
      //_initialFitDone = true; // Enable this to prevent future auto-zooming
    }
  }

  LatLngBounds _getLatLngBounds(Set<Marker> markers) {
    var latitudes = markers.map((m) => m.position.latitude);
    var longitudes = markers.map((m) => m.position.longitude);
    return LatLngBounds(
      southwest: LatLng(latitudes.reduce(min), longitudes.reduce(min)),
      northeast: LatLng(latitudes.reduce(max), longitudes.reduce(max)),
    );
  }

  void _requestPermission() async {
    final bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      await location.requestService();
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _listenLocationChanges() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      _databaseService.updateUserLocation(currentLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = _markers.isNotEmpty
        ? _markers.first.position
        : const LatLng(51.509865, -0.118092); // Default position
    double initialZoom =
        _markers.isNotEmpty ? 12.0 : 10.0; // Adjust zoom level as needed

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: initialPosition, zoom: initialZoom),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}