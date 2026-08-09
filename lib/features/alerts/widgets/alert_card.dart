import 'package:flutter/material.dart';

import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertCard({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: alert.severityColor.withOpacity(.15),
                    child: Icon(alert.severityIcon, color: alert.severityColor),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          alert.deviceName,
                          style: TextStyle(color: Colors.grey.shade700),
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
                      color: alert.severityColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      alert.severityText,
                      style: TextStyle(
                        color: alert.severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                alert.description,
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),

                  const SizedBox(width: 5),

                  Expanded(
                    child: Text(
                      alert.location,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(Icons.thermostat, size: 18, color: Colors.red.shade400),

                  const SizedBox(width: 5),

                  Text("${alert.temperature}°C"),

                  const Spacer(),

                  const Icon(Icons.access_time, size: 18, color: Colors.grey),

                  const SizedBox(width: 5),

                  Text(alert.time),
                ],
              ),

              const SizedBox(height: 15),

              Divider(color: Colors.grey.shade300),

              Row(
                children: [
                  Icon(
                    alert.acknowledged
                        ? Icons.check_circle
                        : Icons.error_outline,
                    size: 18,
                    color: alert.acknowledged ? Colors.green : Colors.orange,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    alert.acknowledged
                        ? "Acknowledged"
                        : "Pending Acknowledgement",
                    style: TextStyle(
                      color: alert.acknowledged ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
