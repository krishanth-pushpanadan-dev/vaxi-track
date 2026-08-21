import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';
import 'package:vaxi_track/app/app_routes.dart';

import '../../authentication/models/user_model.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';

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
  // FIX: Scaffold key for opening the drawer safely
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AuthService _authService = AuthService();

  final int _currentIndex = 0;

  UserModel? get currentUser => _authService.currentUser;

  Future<void> refreshDashboard() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Dashboard refreshed")));
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        break;

      case 1:
        if (currentUser != null &&
            RolePermissions.canViewDevices(currentUser!.role)) {
          Navigator.pushReplacementNamed(context, AppRoutes.devices);
        } else {
          _showAccessDenied();
        }
        break;

      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.batches);
        break;

      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.alerts);
        break;
    }
  }

  void _showAccessDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You don't have permission to access this feature."),
      ),
    );
  }

  void _logout() {
    _authService.logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      // FIX: Attach key to Scaffold
      key: _scaffoldKey,

      backgroundColor: const Color(0xffF6F8FC),

      // ============================================================
      // DRAWER
      // ============================================================
      drawer: _buildDrawer(user),

      body: RefreshIndicator(
        onRefresh: refreshDashboard,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [
              DashboardHeader(
                userName: user?.name ?? "User",
                userRole: user?.roleName ?? "User",
                notificationCount: 3,

                // FIX: Open drawer using Scaffold key
                onMenuPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),

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

              _buildInventorySummary(),

              const SizedBox(height: 25),

              _buildOrderSummary(),

              const SizedBox(height: 25),

              _buildBatchSummary(),

              const SizedBox(height: 25),

              _buildRecentActivity(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  // ================================================================
  // DRAWER
  // ================================================================

  Widget _buildDrawer(UserModel? user) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // --------------------------------------------------------
            // Drawer Header
            // --------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 38, color: Colors.white),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    user?.name ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      user?.roleName ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------------
            // Dashboard
            // --------------------------------------------------------
            _drawerItem(
              icon: Icons.dashboard_rounded,
              title: "Dashboard",
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // --------------------------------------------------------
            // Inventory
            // --------------------------------------------------------
            if (user != null && RolePermissions.canViewInventory(user.role))
              _drawerItem(
                icon: Icons.inventory_2_rounded,
                title: "Inventory",
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, AppRoutes.inventory);
                },
              ),

            // --------------------------------------------------------
            // Order Requests
            // --------------------------------------------------------
            if (user != null && RolePermissions.canViewOrderRequests(user.role))
              _drawerItem(
                icon: Icons.shopping_cart_rounded,
                title: "Order Requests",
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, AppRoutes.orderRequests);
                },
              ),

            // --------------------------------------------------------
            // Waste Management
            // --------------------------------------------------------
            if (user != null && RolePermissions.canViewWaste(user.role))
              _drawerItem(
                icon: Icons.delete_sweep_rounded,
                title: "Waste Management",
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, AppRoutes.waste);
                },
              ),

            // --------------------------------------------------------
            // Maintenance
            // --------------------------------------------------------
            if (user != null && RolePermissions.canViewMaintenance(user.role))
              _drawerItem(
                icon: Icons.build_rounded,
                title: "Maintenance",
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, AppRoutes.maintenance);
                },
              ),

            // --------------------------------------------------------
            // Reports
            // --------------------------------------------------------
            if (user != null && RolePermissions.canViewReports(user.role))
              _drawerItem(
                icon: Icons.bar_chart_rounded,
                title: "Reports",
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, AppRoutes.reports);
                },
              ),

            const Divider(height: 25, indent: 16, endIndent: 16),

            // --------------------------------------------------------
            // Settings
            // --------------------------------------------------------
            if (user != null && RolePermissions.canAccessSettings(user.role))
              _drawerItem(
                icon: Icons.settings_rounded,
                title: "Settings",
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),

            const Spacer(),

            // --------------------------------------------------------
            // Logout
            // --------------------------------------------------------
            _drawerItem(
              icon: Icons.logout_rounded,
              title: "Logout",
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: _logout,
            ),

            const SizedBox(height: 15),

            const Text(
              "VaxiTrack Sri Lanka",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),

      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),

      onTap: onTap,
    );
  }

  // ================================================================
  // OVERVIEW
  // ================================================================

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
                onTap: () {
                  if (currentUser != null &&
                      RolePermissions.canViewDevices(currentUser!.role)) {
                    Navigator.pushNamed(context, AppRoutes.devices);
                  } else {
                    _showAccessDenied();
                  }
                },
              ),

              StatCard(
                title: "Alerts",
                value: "3",
                subtitle: "Critical",
                icon: Icons.warning_amber,
                status: StatCardStatus.danger,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.alerts);
                },
              ),

              StatCard(
                title: "Batches",
                value: "12",
                subtitle: "Active",
                icon: Icons.vaccines,
                status: StatCardStatus.normal,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.batches);
                },
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

  // ================================================================
  // ENVIRONMENT
  // ================================================================

  Widget _buildEnvironment() {
    if (currentUser != null &&
        !RolePermissions.canViewDevices(currentUser!.role)) {
      return const SizedBox.shrink();
    }

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

            children: const [
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

  // ================================================================
  // QUICK ACTIONS
  // ================================================================

  Widget _buildQuickActions() {
    final user = currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final actions = <Widget>[];

    if (RolePermissions.canAddDevice(user.role)) {
      actions.add(
        QuickActionCard(
          title: "Register Device",
          subtitle: "Add new IoT device",
          icon: Icons.add_box_outlined,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addDevice);
          },
        ),
      );
    }

    if (RolePermissions.canAddBatch(user.role)) {
      actions.add(
        QuickActionCard(
          title: "Add Batch",
          subtitle: "Create vaccine batch",
          icon: Icons.vaccines_outlined,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addBatch);
          },
        ),
      );
    }

    if (RolePermissions.canScanQR(user.role)) {
      actions.add(
        QuickActionCard(
          title: "Scan QR",
          subtitle: "Scan vaccine QR",
          icon: Icons.qr_code_scanner,
          onTap: () {},
        ),
      );
    }

    if (RolePermissions.canViewInventory(user.role)) {
      actions.add(
        QuickActionCard(
          title: "Inventory",
          subtitle: "Manage vaccine stock",
          icon: Icons.inventory_2_outlined,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.inventory);
          },
        ),
      );
    }

    if (RolePermissions.canCreateOrderRequest(user.role)) {
      actions.add(
        QuickActionCard(
          title: "Order Request",
          subtitle: "Request vaccine stock",
          icon: Icons.shopping_cart_outlined,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.orderRequests);
          },
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SectionHeader(
            icon: Icons.flash_on,
            title: "Quick Actions",
            subtitle: "Available actions for your role",
          ),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            crossAxisCount: 2,

            crossAxisSpacing: 15,
            mainAxisSpacing: 15,

            childAspectRatio: 1.1,

            children: actions,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // DEVICES
  // ================================================================

  Widget _buildDevices() {
    if (currentUser != null &&
        !RolePermissions.canViewDevices(currentUser!.role)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        children: [
          SectionHeader(
            icon: Icons.memory,
            title: "Connected Devices",
            subtitle: "24 registered devices",
            actionText: "View All",
            onActionPressed: () {
              Navigator.pushNamed(context, AppRoutes.devices);
            },
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

  // ================================================================
  // ALERTS
  // ================================================================

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
            onActionPressed: () {
              Navigator.pushNamed(context, AppRoutes.alerts);
            },
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

  // ================================================================
  // INVENTORY SUMMARY
  // ================================================================

  Widget _buildInventorySummary() {
    final user = currentUser;

    if (user == null || !RolePermissions.canViewInventory(user.role)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        children: [
          SectionHeader(
            icon: Icons.inventory_2_rounded,
            title: "Inventory",
            subtitle: "Vaccine stock overview",
            actionText: "View All",
            onActionPressed: () {
              Navigator.pushNamed(context, AppRoutes.inventory);
            },
          ),

          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Row(
              children: [
                Expanded(
                  child: _inventoryItem(
                    Icons.vaccines,
                    "1,850",
                    "Available Doses",
                    Colors.green,
                  ),
                ),

                Expanded(
                  child: _inventoryItem(
                    Icons.warning_amber,
                    "3",
                    "Low Stock",
                    Colors.orange,
                  ),
                ),

                Expanded(
                  child: _inventoryItem(
                    Icons.error_outline,
                    "2",
                    "Expiring Soon",
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),

        const SizedBox(height: 8),

        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  // ================================================================
  // ORDER REQUEST SUMMARY
  // ================================================================

  Widget _buildOrderSummary() {
    final user = currentUser;

    if (user == null || !RolePermissions.canViewOrderRequests(user.role)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        children: [
          SectionHeader(
            icon: Icons.shopping_cart_rounded,
            title: "Order Requests",
            subtitle: "Vaccine supply requests",
            actionText: "View All",
            onActionPressed: () {
              Navigator.pushNamed(context, AppRoutes.orderRequests);
            },
          ),

          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              children: [
                _orderRow("Pending", "5", Colors.orange, Icons.pending_actions),

                const Divider(),

                _orderRow(
                  "Approved",
                  "8",
                  Colors.blue,
                  Icons.check_circle_outline,
                ),

                const Divider(),

                _orderRow(
                  "Delivered",
                  "14",
                  Colors.green,
                  Icons.local_shipping_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderRow(String title, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // BATCH SUMMARY
  // ================================================================

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
            onActionPressed: () {
              Navigator.pushNamed(context, AppRoutes.batches);
            },
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

  // ================================================================
  // RECENT ACTIVITY
  // ================================================================

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

          const ActivityTile(
            icon: Icons.memory,
            color: Colors.blue,
            title: "Device Connected",
            subtitle: "ESP32 Cold Box A came online.",
            time: "2 min ago",
          ),

          const ActivityTile(
            icon: Icons.thermostat,
            color: Colors.red,
            title: "Temperature Updated",
            subtitle: "Cold Room A reached 4.5°C.",
            time: "8 min ago",
          ),

          const ActivityTile(
            icon: Icons.vaccines,
            color: Colors.green,
            title: "Batch Registered",
            subtitle: "Pfizer Batch PF-2026-102 added.",
            time: "20 min ago",
          ),

          const ActivityTile(
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
