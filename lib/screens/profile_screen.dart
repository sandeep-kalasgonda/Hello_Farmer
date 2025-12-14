import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hello_farmer/models/user.dart' as model;
import 'package:hello_farmer/services/database.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<model.CustomUser?>(context);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService(uid: currentUser.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Could not load profile")),
          );
        }

        final userData =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final String mobileNumber =
            userData['mobileNumber'] ?? 'Not available';

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),

          // 🔝 APP BAR
          appBar: AppBar(
            backgroundColor: Colors.green.shade700,
            elevation: 0,
            title: const Text("My Profile"),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // 👤 PROFILE HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userEmail ?? "Farmer",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 📄 PROFILE DETAILS
                _infoCard(
                  title: "Email",
                  value: userEmail ?? "Not available",
                  icon: Icons.email,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  title: "Mobile Number",
                  value: mobileNumber,
                  icon: Icons.phone,
                ),

                const SizedBox(height: 30),

                // ✏️ EDIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      // TODO: Navigate to Edit Profile screen
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI HELPERS =================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
