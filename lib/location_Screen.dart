import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LocationData? currentLocation;
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  Polyline? polyline;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    startLocationUpdates();
  }

  void getCurrentLocation() async {
    try {
      currentLocation = await location.getLocation();
      updateMarkerAndPolyline(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
      mapController!.animateCamera(CameraUpdate.newLatLng(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!)));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void startLocationUpdates() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      LocationData locationData = await location.getLocation();
      updateMarkerAndPolyline(
          LatLng(locationData.latitude!, locationData.longitude!));
    });
  }

  void updateMarkerAndPolyline(LatLng latLng) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId("myLocation"),
          position: latLng,
          onTap: () {
            showInfoDialog(context, latLng);
          },
        ),
      );

      if (currentLocation != null) {
        polylineCoordinates.add(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
        polyline = Polyline(
          polylineId: const PolylineId("poly"),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        );
      }
      currentLocation = LocationData.fromMap(
          {'latitude': latLng.latitude, 'longitude': latLng.longitude});
    });
  }

  void showInfoDialog(BuildContext context, LatLng latLng) {
    showAdaptiveDialog(
      barrierColor: const Color.fromARGB(0, 104, 104, 104),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('My current location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${latLng.latitude},${latLng.longitude}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google map'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: markers,
        polylines: Set<Polyline>.of(polyline != null ? [polyline!] : []),
      ),
    );
  }
}
