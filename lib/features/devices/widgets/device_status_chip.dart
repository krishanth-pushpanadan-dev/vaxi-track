import 'package:flutter/material.dart';

enum DeviceConnectionStatus { online, warning, offline }

class DeviceStatusChip extends StatelessWidget {
  final DeviceConnectionStatus status;

  const DeviceStatusChip({super.key, required this.status});

  Color get color {
    switch (status) {
      case DeviceConnectionStatus.online:
        return Colors.green;

      case DeviceConnectionStatus.warning:
        return Colors.orange;

      case DeviceConnectionStatus.offline:
        return Colors.red;
    }
  }

  String get label {
    switch (status) {
      case DeviceConnectionStatus.online:
        return "ONLINE";

      case DeviceConnectionStatus.warning:
        return "WARNING";

      case DeviceConnectionStatus.offline:
        return "OFFLINE";
    }
  }

  IconData get icon {
    switch (status) {
      case DeviceConnectionStatus.online:
        return Icons.check_circle;

      case DeviceConnectionStatus.warning:
        return Icons.warning_amber_rounded;

      case DeviceConnectionStatus.offline:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),

          const SizedBox(width: 5),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
