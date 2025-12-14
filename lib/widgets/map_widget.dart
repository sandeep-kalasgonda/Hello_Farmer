import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final Set<Polygon> polygons;
  final Set<Marker> markers;
  final Function(LatLng) onMapTapped;

  const MapWidget({
    super.key,
    required this.polygons,
    required this.markers,
    required this.onMapTapped,
  });

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.5937, 78.9629), // Default to India
    zoom: 5,
  );

  Future<void> goToCurrentUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ));
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid, // Set to hybrid view
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      padding: const EdgeInsets.only(bottom: 250),
      polygons: widget.polygons,
      markers: widget.markers, // Add markers to the map
      onTap: widget.onMapTapped,
    );
  }
}
