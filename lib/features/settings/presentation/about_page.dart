import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("About VaxiTrack"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.vaccines, color: Colors.white, size: 50),
            ),

            const SizedBox(height: 20),

            const Text(
              "VaxiTrack",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "IoT Vaccine Cold Chain Monitoring System",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),

            const SizedBox(height: 30),

            buildInfoTile(
              icon: Icons.info_outline,
              title: "Version",
              value: "1.0.0",
            ),

            buildInfoTile(
              icon: Icons.school,
              title: "Project",
              value: "Final Year Project",
            ),

            buildInfoTile(
              icon: Icons.business,
              title: "Organization",
              value: "University of Moratuwa",
            ),

            buildInfoTile(
              icon: Icons.code,
              title: "Technology",
              value: "Flutter • Firebase • ESP32",
            ),

            buildInfoTile(
              icon: Icons.copyright,
              title: "Copyright",
              value: "© 2026 VaxiTrack. All Rights Reserved.",
            ),

            const SizedBox(height: 30),

            Text(
              "VaxiTrack is designed to monitor vaccine cold chain conditions using IoT technology. "
              "It helps healthcare organizations monitor temperature, humidity, battery level, "
              "device location, and vaccine batch information in real time.",
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
