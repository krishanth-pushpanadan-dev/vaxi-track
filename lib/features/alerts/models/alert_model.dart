import 'package:flutter/material.dart';

enum AlertSeverity { critical, warning, info }

enum AlertStatus { active, resolved }

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String deviceName;
  final String location;
  final String time;
  final double temperature;
  final AlertSeverity severity;
  final AlertStatus status;
  final bool acknowledged;

  const AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deviceName,
    required this.location,
    required this.time,
    required this.temperature,
    required this.severity,
    required this.status,
    required this.acknowledged,
  });

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;

      case AlertSeverity.warning:
        return Colors.orange;

      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.warning_rounded;

      case AlertSeverity.warning:
        return Icons.report_problem_rounded;

      case AlertSeverity.info:
        return Icons.info_rounded;
    }
  }

  String get severityText {
    switch (severity) {
      case AlertSeverity.critical:
        return "Critical";

      case AlertSeverity.warning:
        return "Warning";

      case AlertSeverity.info:
        return "Information";
    }
  }

  Color get statusColor {
    switch (status) {
      case AlertStatus.active:
        return Colors.red;

      case AlertStatus.resolved:
        return Colors.green;
    }
  }

  String get statusText {
    switch (status) {
      case AlertStatus.active:
        return "Active";

      case AlertStatus.resolved:
        return "Resolved";
    }
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      deviceName: json["deviceName"],
      location: json["location"],
      time: json["time"],
      temperature: (json["temperature"] as num).toDouble(),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json["severity"],
      ),
      status: AlertStatus.values.firstWhere((e) => e.name == json["status"]),
      acknowledged: json["acknowledged"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "deviceName": deviceName,
      "location": location,
      "time": time,
      "temperature": temperature,
      "severity": severity.name,
      "status": status.name,
      "acknowledged": acknowledged,
    };
  }
}
