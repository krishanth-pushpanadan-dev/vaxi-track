import 'package:flutter/material.dart';

import '../features/splash/presentation/splash_page.dart';
import '../features/authentication/presentation/login_page.dart';
import '../features/authentication/presentation/signup_page.dart';
import '../features/authentication/presentation/forgot_password_page.dart';

import '../features/dashboard/presentation/dashboard_page.dart';

import '../features/devices/presentation/devices_page.dart';
import '../features/vaccine_batches/presentation/batches_page.dart';
import '../features/alerts/presentation/alerts_page.dart';
import '../features/settings/presentation/settings_page.dart';

// ============================================================
// IMPLEMENTED BUSINESS FEATURES
// ============================================================

import '../features/inventory/presentation/inventory_page.dart';
import '../features/inventory/presentation/add_stock_page.dart';
import '../features/order_requests/presentation/order_requests_page.dart';

// ============================================================
// ADD THESE IMPORTS WHEN THE PAGES EXIST
// ============================================================
//

// import '../features/waste/presentation/waste_page.dart';
// import '../features/maintenance/presentation/maintenance_page.dart';
// import '../features/reports/presentation/reports_page.dart';
// import '../features/user_management/presentation/user_management_page.dart';
// import '../features/devices/presentation/add_device_page.dart';
// import '../features/vaccine_batches/presentation/add_batch_page.dart';

class AppRoutes {
  AppRoutes._();

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  static const String splash = "/";

  static const String login = "/login";

  static const String signup = "/signup";

  static const String forgotPassword = "/forgot-password";

  // ============================================================
  // MAIN NAVIGATION
  // ============================================================

  static const String dashboard = "/dashboard";

  static const String devices = "/dashboard/devices";

  static const String batches = "/dashboard/batches";

  static const String alerts = "/dashboard/alerts";

  static const String settings = "/dashboard/settings";

  // ============================================================
  // DEVICE
  // ============================================================

  static const String addDevice = "/dashboard/devices/add";

  // ============================================================
  // VACCINE BATCH
  // ============================================================

  static const String addBatch = "/dashboard/batches/add";

  // ============================================================
  // INVENTORY
  // ============================================================

  static const String inventory = "/dashboard/inventory";

  static const String addStock = "/dashboard/inventory/add-stock";

  // ============================================================
  // OTHER BUSINESS FEATURES
  // ============================================================

  static const String orderRequests = "/dashboard/order-requests";

  static const String waste = "/dashboard/waste";

  static const String maintenance = "/dashboard/maintenance";

  static const String reports = "/dashboard/reports";

  static const String userManagement = "/dashboard/user-management";

  // ============================================================
  // ROUTE MAP
  // ============================================================

  static final Map<String, WidgetBuilder> routes = {
    // ----------------------------------------------------------
    // AUTHENTICATION
    // ----------------------------------------------------------
    splash: (_) => const SplashPage(),

    login: (_) => const LoginPage(),

    signup: (_) => const SignupPage(),

    forgotPassword: (_) => const ForgotPasswordPage(),

    // ----------------------------------------------------------
    // MAIN
    // ----------------------------------------------------------
    dashboard: (_) => const DashboardPage(),

    devices: (_) => const DevicesPage(),

    batches: (_) => const BatchesPage(),

    alerts: (_) => const AlertsPage(),

    settings: (_) => const SettingsPage(),

    // ----------------------------------------------------------
    // INVENTORY
    // ----------------------------------------------------------
    inventory: (_) => const InventoryPage(),

    addStock: (_) => const AddStockPage(),

    // ----------------------------------------------------------
    // OTHER BUSINESS FEATURES
    // ----------------------------------------------------------
    orderRequests: (_) => const OrderRequestsPage(),

    // waste: (_) => const WastePage(),

    // maintenance: (_) => const MaintenancePage(),

    // reports: (_) => const ReportsPage(),

    // userManagement: (_) => const UserManagementPage(),

    // ----------------------------------------------------------
    // ADD / CREATE PAGES
    // ----------------------------------------------------------

    // addDevice: (_) => const AddDevicePage(),

    // addBatch: (_) => const AddBatchPage(),
  };
}
