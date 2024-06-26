import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hikiddo/models/location.dart';
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
  StreamSubscription<List<UserLocation>>? _locationUpdates;
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
    _locationUpdates?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialPosition = _markers.isNotEmpty
        ? _markers.first.position
        : const LatLng(51.509865, -0.118092); // Default position
    double initialZoom = _markers.isNotEmpty ? 12.0 : 10.0;

    return PopScope(
      canPop: false,
      child: MaterialApp(
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
      ),
    );
  }

  Future<void> _setupFamilyGroupMarkers() async {
    String? familyGroupId = await _databaseService.getFamilyGroupId(context);
    if (familyGroupId != null) {
      _listenForLocationUpdates(familyGroupId);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have not joined a Family Group yet")),
      );
    }
  }

  void _listenForLocationUpdates(String familyGroupId) {
    _locationUpdates
        ?.cancel();
    _locationUpdates = _databaseService
        .getFamilyGroupUserLocationsStream(familyGroupId)
        .listen(
      (locations) async {
        await _updateMarkers(locations);
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error listening for location updates")),
        );
      },
    );
  }

  Future<void> _updateMarkers(List<UserLocation> locations) async {
    Set<Marker> newMarkers = {};
    for (var userLocation in locations) {
      // Use a default image URL if none is found
      String profileImageUrl = userLocation.profileImageUrl;
      final BitmapDescriptor icon =
          await getMarkerIconFromUrl(profileImageUrl, const Size(150, 150));

      final marker = Marker(
        markerId: MarkerId(userLocation.userId),
        position: userLocation.latLng,
        icon: icon,
        infoWindow: InfoWindow(title: userLocation.name),
      );

      newMarkers.add(marker);
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
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
}
