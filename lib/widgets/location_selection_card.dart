import 'package:flutter/material.dart';

class LocationSelectionCard extends StatelessWidget {
  const LocationSelectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: Colors.green),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Current Location',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter Destination',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
