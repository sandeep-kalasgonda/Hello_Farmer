import 'package:cloud_firestore/cloud_firestore.dart';

class Tractor {
  final String id;
  final String name;
  final String type;
  final double pricePerHour;
  final GeoPoint location;
  final String imageUrl;
  final String ownerId;

  Tractor({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerHour,
    required this.location,
    required this.imageUrl,
    required this.ownerId,
  });

  factory Tractor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tractor(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      type: data['type'] ?? 'No Type',
      pricePerHour: (data['pricePerHour'] ?? 0.0).toDouble(),
      location: data['location'] ?? const GeoPoint(0, 0),
      imageUrl: data['imageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
    );
  }
}
