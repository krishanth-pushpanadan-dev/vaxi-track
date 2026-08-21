import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_routes.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/authentication/models/role_permissions.dart';
import '../../features/authentication/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      return const Drawer(child: Center(child: Text("User not logged in")));
    }

    final role = user.role;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.roleName,
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

            // =====================================================
            // MENU
            // =====================================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  // -------------------------------------------------
                  // INVENTORY
                  // -------------------------------------------------
                  if (RolePermissions.canViewInventory(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.inventory_2_rounded,
                      title: "Inventory",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.inventory);
                      },
                    ),

                  // -------------------------------------------------
                  // ORDER REQUESTS
                  // -------------------------------------------------
                  if (RolePermissions.canViewOrderRequests(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.shopping_cart_rounded,
                      title: "Order Requests",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.orderRequests);
                      },
                    ),

                  // -------------------------------------------------
                  // WASTE MANAGEMENT
                  // -------------------------------------------------
                  if (RolePermissions.canViewWaste(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.delete_sweep_rounded,
                      title: "Waste Management",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.waste);
                      },
                    ),

                  // -------------------------------------------------
                  // MAINTENANCE
                  // -------------------------------------------------
                  if (RolePermissions.canViewMaintenance(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.build_rounded,
                      title: "Maintenance",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.maintenance);
                      },
                    ),

                  // -------------------------------------------------
                  // REPORTS
                  // -------------------------------------------------
                  if (RolePermissions.canViewReports(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.bar_chart_rounded,
                      title: "Reports",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.reports);
                      },
                    ),

                  // -------------------------------------------------
                  // USER MANAGEMENT
                  // ADMIN ONLY
                  // -------------------------------------------------
                  if (RolePermissions.canManageUsers(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.manage_accounts_rounded,
                      title: "User Management",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.userManagement);
                      },
                    ),

                  const Divider(height: 30, indent: 18, endIndent: 18),

                  // -------------------------------------------------
                  // SETTINGS
                  // -------------------------------------------------
                  if (RolePermissions.canAccessSettings(role))
                    _drawerItem(
                      context: context,
                      icon: Icons.settings_rounded,
                      title: "Settings",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                    ),
                ],
              ),
            ),

            // =====================================================
            // LOGOUT
            // =====================================================
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // DRAWER ITEM
  // ===============================================================

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // ===============================================================
  // LOGOUT
  // ===============================================================

  void _logout(BuildContext context) {
    AuthService().logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
