import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            const Text(
              "Krish",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              "Cold Chain Administrator",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            _buildTile(Icons.email, "Email", "krish@vaxitrack.com"),

            _buildTile(Icons.phone, "Phone", "+94 71 234 5678"),

            _buildTile(Icons.location_on, "Location", "Colombo, Sri Lanka"),

            _buildTile(Icons.badge, "Employee ID", "EMP-001"),

            _buildTile(Icons.business, "Department", "Cold Chain Monitoring"),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
