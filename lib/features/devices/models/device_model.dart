import 'package:vaxi_track/features/dashboard/widgets/device_card.dart';

class DeviceModel {
  final String id;
  final String name;
  final String location;

  final double temperature;
  final double humidity;

  final int battery;
  final int signal;

  final String firmware;
  final String lastSync;

  final bool isOnline;
  final bool hasWarning;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.battery,
    required this.signal,
    required this.firmware,
    required this.lastSync,
    required this.isOnline,
    required this.hasWarning,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      battery: json['battery'],
      signal: json['signal'],
      firmware: json['firmware'],
      lastSync: json['lastSync'],
      isOnline: json['isOnline'],
      hasWarning: json['hasWarning'],
    );
  }

  String get lastUpdated => lastSync;

  DeviceStatus get status {
    if (!isOnline) {
      return DeviceStatus.offline;
    }

    if (hasWarning) {
      return DeviceStatus.warning;
    }

    return DeviceStatus.online;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'battery': battery,
      'signal': signal,
      'firmware': firmware,
      'lastSync': lastSync,
      'isOnline': isOnline,
      'hasWarning': hasWarning,
    };
  }
}
