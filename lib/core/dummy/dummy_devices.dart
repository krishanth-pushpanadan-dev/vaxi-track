import 'package:vaxi_track/features/devices/models/device_model.dart';

final List<DeviceModel> deviceList = [
  DeviceModel(
    id: "D001",
    name: "Cold Room A",
    location: "Colombo",
    temperature: 4.2,
    humidity: 63,
    battery: 98,
    signal: 92,
    firmware: "v2.1.4",
    lastSync: "2 min ago",
    isOnline: true,
    hasWarning: false,
  ),

  DeviceModel(
    id: "D002",
    name: "Freezer B",
    location: "Kandy",
    temperature: -18.4,
    humidity: 55,
    battery: 76,
    signal: 84,
    firmware: "v2.1.4",
    lastSync: "5 min ago",
    isOnline: true,
    hasWarning: false,
  ),

  DeviceModel(
    id: "D003",
    name: "Refrigerator C",
    location: "Jaffna",
    temperature: 9.8,
    humidity: 70,
    battery: 42,
    signal: 40,
    firmware: "v2.0.9",
    lastSync: "12 min ago",
    isOnline: true,
    hasWarning: true,
  ),

  DeviceModel(
    id: "D004",
    name: "Storage Unit D",
    location: "Galle",
    temperature: 5.1,
    humidity: 65,
    battery: 12,
    signal: 0,
    firmware: "v2.0.5",
    lastSync: "1 hour ago",
    isOnline: false,
    hasWarning: true,
  ),
];
