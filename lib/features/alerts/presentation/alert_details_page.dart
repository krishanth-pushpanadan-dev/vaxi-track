import 'package:flutter/material.dart';

import '../models/alert_model.dart';

class AlertDetailsPage extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsPage({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alert Details"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Alert Icon
            CircleAvatar(
              radius: 45,
              backgroundColor: alert.severityColor.withOpacity(.15),
              child: Icon(
                alert.severityIcon,
                size: 45,
                color: alert.severityColor,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              alert.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Chip(
              backgroundColor: alert.severityColor.withOpacity(.15),
              label: Text(
                alert.severityText,
                style: TextStyle(
                  color: alert.severityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            _infoTile(Icons.memory, "Device", alert.deviceName),

            _infoTile(Icons.location_on, "Location", alert.location),

            _infoTile(
              Icons.thermostat,
              "Temperature",
              "${alert.temperature} °C",
            ),

            _infoTile(Icons.schedule, "Time", alert.time),

            _infoTile(Icons.description, "Description", alert.description),

            _infoTile(
              alert.acknowledged ? Icons.check_circle : Icons.error_outline,
              "Status",
              alert.acknowledged ? "Acknowledged" : "Pending",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Acknowledge Alert"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Alert acknowledged successfully"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
