import 'package:flutter/material.dart';

enum BatchStatus { stored, transit, delivered, expired }

class BatchModel {
  final String id;
  final String vaccineName;
  final String batchNumber;
  final String manufacturer;
  final int quantity;
  final String location;
  final String assignedDevice;
  final String manufactureDate;
  final String expiryDate;
  final String storageTemperature;
  final double currentTemperature;
  final BatchStatus status;

  const BatchModel({
    required this.id,
    required this.vaccineName,
    required this.batchNumber,
    required this.manufacturer,
    required this.quantity,
    required this.location,
    required this.assignedDevice,
    required this.manufactureDate,
    required this.expiryDate,
    required this.storageTemperature,
    required this.currentTemperature,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case BatchStatus.stored:
        return Colors.green;

      case BatchStatus.transit:
        return Colors.orange;

      case BatchStatus.delivered:
        return Colors.blue;

      case BatchStatus.expired:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case BatchStatus.stored:
        return "STORED";

      case BatchStatus.transit:
        return "TRANSIT";

      case BatchStatus.delivered:
        return "DELIVERED";

      case BatchStatus.expired:
        return "EXPIRED";
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BatchStatus.stored:
        return Icons.inventory_2;

      case BatchStatus.transit:
        return Icons.local_shipping;

      case BatchStatus.delivered:
        return Icons.check_circle;

      case BatchStatus.expired:
        return Icons.warning;
    }
  }

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json["id"],
      vaccineName: json["vaccineName"],
      batchNumber: json["batchNumber"],
      manufacturer: json["manufacturer"],
      quantity: json["quantity"],
      location: json["location"],
      assignedDevice: json["assignedDevice"],
      manufactureDate: json["manufactureDate"],
      expiryDate: json["expiryDate"],
      storageTemperature: json["storageTemperature"],
      currentTemperature: (json["currentTemperature"] as num).toDouble(),
      status: BatchStatus.values.firstWhere((e) => e.name == json["status"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "vaccineName": vaccineName,
      "batchNumber": batchNumber,
      "manufacturer": manufacturer,
      "quantity": quantity,
      "location": location,
      "assignedDevice": assignedDevice,
      "manufactureDate": manufactureDate,
      "expiryDate": expiryDate,
      "storageTemperature": storageTemperature,
      "currentTemperature": currentTemperature,
      "status": status.name,
    };
  }
}
