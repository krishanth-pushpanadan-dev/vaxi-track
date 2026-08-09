import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_routes.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/sensor_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/device_card.dart';
import '../widgets/activity_tile.dart';
import '../widgets/batch_summary_card.dart';
import '../widgets/bottom_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> refreshDashboard() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  final int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;

      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.devices);
        break;

      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.batches);
        break;

      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.alerts);
        break;

      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              DashboardHeader(userName: "Krish", notificationCount: 3),

              _buildOverview(),

              const SizedBox(height: 25),

              _buildEnvironment(),

              const SizedBox(height: 25),

              _buildQuickActions(),

              const SizedBox(height: 25),

              _buildDevices(),

              const SizedBox(height: 25),

              _buildAlerts(),

              const SizedBox(height: 25),

              _buildBatchSummary(),

              const SizedBox(height: 25),

              _buildRecentActivity(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.dashboard_rounded,
            title: "Overview",
            subtitle: "System health at a glance",
          ),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.85,
            children: [
              StatCard(
                title: "Devices",
                value: "24",
                subtitle: "22 Online",
                icon: Icons.memory,
                status: StatCardStatus.success,
                onTap: () {},
              ),

              StatCard(
                title: "Alerts",
                value: "3",
                subtitle: "Critical",
                icon: Icons.warning_amber,
                status: StatCardStatus.danger,
                onTap: () {},
              ),

              StatCard(
                title: "Batches",
                value: "12",
                subtitle: "Active",
                icon: Icons.vaccines,
                status: StatCardStatus.normal,
                onTap: () {},
              ),

              StatCard(
                title: "Compliance",
                value: "96%",
                subtitle: "Healthy",
                icon: Icons.health_and_safety,
                status: StatCardStatus.success,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironment() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.sensors,
            title: "Live Environment",
            subtitle: "Real-time IoT sensor readings",
          ),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: .85,
            children: [
              SensorCard(
                title: "Temperature",
                value: "4.6",
                unit: "°C",
                icon: Icons.thermostat,
                description: "Safe Storage",
              ),

              SensorCard(
                title: "Humidity",
                value: "67",
                unit: "%",
                icon: Icons.water_drop,
                description: "Optimal",
              ),

              SensorCard(
                title: "Battery",
                value: "91",
                unit: "%",
                icon: Icons.battery_full,
                description: "Excellent",
              ),

              SensorCard(
                title: "Signal",
                value: "-63",
                unit: " dBm",
                icon: Icons.wifi,
                description: "Strong",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.flash_on,
            title: "Quick Actions",
            subtitle: "Frequently used actions",
          ),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              QuickActionCard(
                title: "Register Device",
                subtitle: "Add new IoT device",
                icon: Icons.add_box_outlined,
                onTap: () {},
              ),

              QuickActionCard(
                title: "Add Batch",
                subtitle: "Create vaccine batch",
                icon: Icons.vaccines_outlined,
                onTap: () {},
              ),

              QuickActionCard(
                title: "Scan QR",
                subtitle: "Scan vaccine QR",
                icon: Icons.qr_code_scanner,
                onTap: () {},
              ),

              QuickActionCard(
                title: "Reports",
                subtitle: "Analytics & Export",
                icon: Icons.bar_chart_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SectionHeader(
            icon: Icons.notifications_active,
            title: "Recent Alerts",
            subtitle: "3 active alerts",
            actionText: "See All",
            onActionPressed: () {},
          ),

          AlertCard(
            title: "High Temperature",
            deviceName: "Cold Storage Unit A",
            location: "Colombo General Hospital",
            time: "2 min ago",
            severity: AlertSeverity.critical,
            acknowledged: false,
            onTap: () {},
          ),

          AlertCard(
            title: "Battery Low",
            deviceName: "ESP32 Device 04",
            location: "Kandy MOH",
            time: "15 min ago",
            severity: AlertSeverity.warning,
            acknowledged: false,
            onTap: () {},
          ),

          AlertCard(
            title: "Door Open",
            deviceName: "Storage Room 2",
            location: "Galle District Hospital",
            time: "48 min ago",
            severity: AlertSeverity.info,
            acknowledged: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDevices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SectionHeader(
            icon: Icons.memory,
            title: "Connected Devices",
            subtitle: "24 registered devices",
            actionText: "View All",
            onActionPressed: () {},
          ),

          DeviceCard(
            deviceName: "ESP32 Cold Box A",
            location: "Colombo General Hospital",
            temperature: 4.8,
            humidity: 65,
            battery: 92,
            signal: 95,
            lastUpdated: "5 sec ago",
            status: DeviceStatus.online,
            onTap: () {},
          ),

          DeviceCard(
            deviceName: "ESP32 Cold Box B",
            location: "Kandy Regional Hospital",
            temperature: 8.5,
            humidity: 74,
            battery: 24,
            signal: 72,
            lastUpdated: "1 min ago",
            status: DeviceStatus.warning,
            onTap: () {},
          ),

          DeviceCard(
            deviceName: "ESP32 Cold Box C",
            location: "Jaffna MOH Office",
            temperature: 0,
            humidity: 0,
            battery: 0,
            signal: 0,
            lastUpdated: "18 min ago",
            status: DeviceStatus.offline,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBatchSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.vaccines,
            title: "Vaccine Batches",
            subtitle: "Cold chain inventory",
            actionText: "Manage",
            onActionPressed: () {},
          ),

          BatchSummaryCard(
            batchName: "VX-2026-001",
            vaccineName: "Pfizer COVID-19",
            totalDoses: 1200,
            availableDoses: 980,
            expiryDate: "15 Aug 2026",
            status: BatchStatus.normal,
            onTap: () {},
          ),

          BatchSummaryCard(
            batchName: "VX-2026-002",
            vaccineName: "BCG Vaccine",
            totalDoses: 800,
            availableDoses: 120,
            expiryDate: "05 Jul 2026",
            status: BatchStatus.expiring,
            onTap: () {},
          ),

          BatchSummaryCard(
            batchName: "VX-2026-003",
            vaccineName: "MMR Vaccine",
            totalDoses: 650,
            availableDoses: 0,
            expiryDate: "28 Jun 2026",
            status: BatchStatus.expired,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SectionHeader(
            icon: Icons.history,
            title: "Recent Activity",
            subtitle: "Latest system events",
            actionText: "View All",
            onActionPressed: () {},
          ),

          ActivityTile(
            icon: Icons.memory,
            color: Colors.blue,
            title: "Device Connected",
            subtitle: "ESP32 Cold Box A came online.",
            time: "2 min ago",
          ),

          ActivityTile(
            icon: Icons.thermostat,
            color: Colors.red,
            title: "Temperature Updated",
            subtitle: "Cold Room A reached 4.5°C.",
            time: "8 min ago",
          ),

          ActivityTile(
            icon: Icons.vaccines,
            color: Colors.green,
            title: "Batch Registered",
            subtitle: "Pfizer Batch PF-2026-102 added.",
            time: "20 min ago",
          ),

          ActivityTile(
            icon: Icons.check_circle,
            color: Colors.orange,
            title: "Alert Resolved",
            subtitle: "High temperature alert acknowledged.",
            time: "45 min ago",
          ),
        ],
      ),
    );
  }
}
