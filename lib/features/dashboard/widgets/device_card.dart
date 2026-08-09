import 'package:flutter/material.dart';

enum DeviceStatus { online, warning, offline }

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String location;
  final double temperature;
  final double humidity;
  final int battery;
  final int signal;
  final String lastUpdated;
  final DeviceStatus status;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.battery,
    required this.signal,
    required this.lastUpdated,
    this.status = DeviceStatus.online,
    this.onTap,
  });

  Color get statusColor {
    switch (status) {
      case DeviceStatus.online:
        return Colors.green;
      case DeviceStatus.warning:
        return Colors.orange;
      case DeviceStatus.offline:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case DeviceStatus.online:
        return "ONLINE";
      case DeviceStatus.warning:
        return "WARNING";
      case DeviceStatus.offline:
        return "OFFLINE";
    }
  }

  IconData get statusIcon {
    switch (status) {
      case DeviceStatus.online:
        return Icons.check_circle;
      case DeviceStatus.warning:
        return Icons.warning;
      case DeviceStatus.offline:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              /// Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.memory, color: statusColor, size: 30),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),

                        const SizedBox(width: 5),

                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Divider(color: Colors.grey.shade300),

              const SizedBox(height: 18),

              /// Sensor Values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _sensor(
                    Icons.thermostat,
                    "${temperature.toStringAsFixed(1)}°C",
                    "Temperature",
                    Colors.red,
                  ),

                  _sensor(
                    Icons.water_drop,
                    "${humidity.toStringAsFixed(0)}%",
                    "Humidity",
                    Colors.blue,
                  ),

                  _sensor(
                    Icons.battery_full,
                    "$battery%",
                    "Battery",
                    Colors.green,
                  ),

                  _sensor(Icons.wifi, "$signal%", "Signal", Colors.orange),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),

                  const SizedBox(width: 5),

                  Text(
                    "Updated $lastUpdated",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const Spacer(),

                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: const Text("View"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensor(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        const SizedBox(height: 2),

        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
