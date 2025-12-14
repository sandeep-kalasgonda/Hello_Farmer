import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_farmer/screens/profile_screen.dart';
import 'package:hello_farmer/services/auth_service.dart';
import 'package:hello_farmer/widgets/map_widget.dart';
import 'package:hello_farmer/widgets/nearby_card.dart';
import 'package:hello_farmer/widgets/service_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:geocoding/geocoding.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _auth = AuthService();
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey();

  // State for polygon drawing
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  final List<LatLng> _polygonLatLngs = [];
  bool _isDrawingPolygon = false;
  double _calculatedArea = 0.0;

  // State for reverse geocoding
  String _currentAddress = "Getting location...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _goToCurrentUserLocation();
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        _goToCurrentUserLocation();
      }
    }
  }

  Future<void> _goToCurrentUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _getAddressFromLatLng(position); // Get address from location
      _mapKey.currentState?.goToCurrentUserLocation();
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _currentAddress = "Could not get location";
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Construct a readable address. Village name could be in several fields.
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      } else {
        setState(() {
          _currentAddress = "Address not found";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
      setState(() {
        _currentAddress = "Could not get address";
      });
    }
  }

  void _toggleDrawingMode() {
    setState(() {
      _isDrawingPolygon = !_isDrawingPolygon;
      if (!_isDrawingPolygon) {
        _clearPolygon();
      }
    });
  }

  void _onMapTapped(LatLng point) {
    if (_isDrawingPolygon) {
      setState(() {
        _polygonLatLngs.add(point);
        _updatePolygonAndMarkers();
      });
    }
  }

  void _updatePolygonAndMarkers() {
    _polygons.clear();
    _markers.clear();

    for (int i = 0; i < _polygonLatLngs.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: _polygonLatLngs[i],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    }

    if (_polygonLatLngs.length > 1) {
      _polygons.add(
        Polygon(
          polygonId: const PolygonId('field'),
          points: _polygonLatLngs,
          strokeWidth: 2,
          strokeColor: Colors.orange,
          fillColor: Colors.orange.withOpacity(0.3),
        ),
      );
    }
    _calculateArea();
  }

  void _clearPolygon() {
    setState(() {
      _polygonLatLngs.clear();
      _polygons.clear();
      _markers.clear();
      _calculatedArea = 0.0;
    });
  }

  void _calculateArea() {
    if (_polygonLatLngs.length > 2) {
      final points = _polygonLatLngs
          .map((p) => maps_toolkit.LatLng(p.latitude, p.longitude))
          .toList();
      final double areaInMeters = maps_toolkit.SphericalUtil.computeArea(points).toDouble();
      _calculatedArea = areaInMeters / 4046.86;
    } else {
      _calculatedArea = 0.0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDrawingPolygon ? Icons.edit_off : Icons.edit,
              color: _isDrawingPolygon ? Colors.green : Colors.black87,
            ),
            tooltip: 'Draw Polygon',
            onPressed: _toggleDrawingMode,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(
            key: _mapKey,
            polygons: _isDrawingPolygon ? _polygons : const {},
            markers: _isDrawingPolygon ? _markers : const {},
            onMapTapped: _onMapTapped,
          ),
          if (!_isDrawingPolygon)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.3 + 10,
              left: 10,
              right: 10,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _currentAddress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          if (_isDrawingPolygon)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Area: ${_calculatedArea.toStringAsFixed(3)} acres',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _clearPolygon,
                        tooltip: 'Clear Polygon',
                      )
                    ],
                  ),
                ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Choose Your Service",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        ServiceCard(
                          icon: Icons.agriculture,
                          label: "Rent Tractor",
                          color: Colors.green,
                        ),
                        ServiceCard(
                          icon: Icons.build,
                          label: "Book Service",
                          color: Colors.blue,
                        ),
                        ServiceCard(
                          icon: Icons.shopping_cart,
                          label: "Buy Tools",
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Nearby Services",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    const NearbyCard(
                      title: "Tractor - John Deere",
                      subtitle: "2.4 km away",
                      price: "₹500/hr",
                      imageUrl: "https://picsum.photos/100",
                    ),
                    const SizedBox(height: 12),
                    const NearbyCard(
                      title: "Tiller Machine",
                      subtitle: "1.1 km away",
                      price: "₹300/hr",
                      imageUrl: "https://picsum.photos/101",
                    ),
                    const SizedBox(height: 12),
                    const NearbyCard(
                      title: "Harvester",
                      subtitle: "3.0 km away",
                      price: "₹1200/hr",
                      imageUrl: "https://picsum.photos/102",
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapKey.currentState?.goToCurrentUserLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
