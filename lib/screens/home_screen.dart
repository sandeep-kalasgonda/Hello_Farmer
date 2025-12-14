import 'package:flutter/material.dart';
import 'package:hello_farmer/widgets/location_selection_card.dart';
import 'package:hello_farmer/widgets/nearby_card.dart';
import 'package:hello_farmer/widgets/service_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationSelectionCard(),
            SizedBox(height: 25),
            Text(
              "Choose Your Service",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
            SizedBox(height: 30),
            Text(
              "Nearby Services",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            NearbyCard(
              title: "Tractor - John Deere",
              subtitle: "2.4 km away",
              price: "₹500/hr",
              imageUrl: "https://picsum.photos/100",
            ),
            SizedBox(height: 12),
            NearbyCard(
              title: "Tiller Machine",
              subtitle: "1.1 km away",
              price: "₹300/hr",
              imageUrl: "https://picsum.photos/101",
            ),
          ],
        ),
      ),
    );
  }
}
