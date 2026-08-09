import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../dashboard/widgets/sensor_card.dart';
import '../../dashboard/widgets/section_header.dart';
import '../../dashboard/widgets/alert_card.dart';
import '../widgets/temperature_chart.dart';

class DeviceDetailsPage extends StatelessWidget {
  final String deviceName;

  const DeviceDetailsPage({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(deviceName),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Device Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.memory, size: 42, color: Colors.white),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    deviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "ONLINE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoTile(
                        icon: Icons.location_on,
                        title: "Location",
                        value: "Colombo",
                      ),

                      _InfoTile(
                        icon: Icons.schedule,
                        title: "Last Sync",
                        value: "2 mins ago",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SectionHeader(
                    icon: Icons.analytics,
                    title: "Live Sensors",
                    subtitle: "Real-time readings",
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: .95,
                    children: const [
                      SensorCard(
                        title: "Temperature",
                        value: "4.2",
                        unit: "°C",
                        icon: Icons.thermostat,
                        description: "Optimal",
                      ),

                      SensorCard(
                        title: "Humidity",
                        value: "65",
                        unit: "%",
                        icon: Icons.water_drop,
                        description: "Stable",
                      ),

                      SensorCard(
                        title: "Battery",
                        value: "89",
                        unit: "%",
                        icon: Icons.battery_full,
                        description: "Healthy",
                      ),

                      SensorCard(
                        title: "Signal",
                        value: "92",
                        unit: "%",
                        icon: Icons.wifi,
                        description: "Excellent",
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SectionHeader(
                    icon: Icons.show_chart,
                    title: "Temperature History",
                    subtitle: "Last 24 hours",
                  ),

                  const SizedBox(height: 15),

                  const TemperatureChart(),

                  const SizedBox(height: 30),

                  SectionHeader(
                    icon: Icons.warning,
                    title: "Recent Alerts",
                    subtitle: "Latest notifications",
                  ),

                  const SizedBox(height: 15),

                  const AlertCard(
                    title: "Temperature Spike",
                    deviceName: "Cold Storage 01",
                    location: "Colombo",
                    time: "15 mins ago",
                    severity: AlertSeverity.warning,
                  ),

                  const SizedBox(height: 30),

                  SectionHeader(
                    icon: Icons.flash_on,
                    title: "Quick Actions",
                    subtitle: "Device controls",
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.restart_alt),
                          label: const Text("Restart"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),

        const SizedBox(height: 5),

        Text(title, style: const TextStyle(color: Colors.white70)),

        const SizedBox(height: 3),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
