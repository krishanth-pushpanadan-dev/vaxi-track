import 'package:flutter/material.dart';

enum AlertSeverity { info, warning, critical }

class AlertCard extends StatelessWidget {
  final String title;
  final String deviceName;
  final String location;
  final String time;
  final AlertSeverity severity;
  final bool acknowledged;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.title,
    required this.deviceName,
    required this.location,
    required this.time,
    required this.severity,
    this.acknowledged = false,
    this.onTap,
  });

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.info:
        return Colors.blue;

      case AlertSeverity.warning:
        return Colors.orange;

      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.info_outline;

      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;

      case AlertSeverity.critical:
        return Icons.error_outline;
    }
  }

  String get severityText {
    switch (severity) {
      case AlertSeverity.info:
        return "INFO";

      case AlertSeverity.warning:
        return "WARNING";

      case AlertSeverity.critical:
        return "CRITICAL";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(severityIcon, color: severityColor, size: 30),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 15,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      severityText,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Icon(
                        acknowledged
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: acknowledged ? Colors.green : Colors.grey,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        acknowledged ? "Resolved" : "Active",
                        style: TextStyle(
                          color: acknowledged ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
