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
// BUSINESS FEATURES
// ============================================================

import '../features/inventory/presentation/inventory_page.dart';
import '../features/inventory/presentation/add_stock_page.dart';

import '../features/order_requests/presentation/order_requests_page.dart';

import '../features/waste_management/presentation/waste_management_page.dart';

// ============================================================
// ADD THESE WHEN THE PAGES ARE READY
// ============================================================

// import '../features/maintenance/presentation/maintenance_page.dart';
// import '../features/reports/presentation/reports_page.dart';
// import '../features/user_management/presentation/user_management_page.dart';

// If these pages already exist in your project, uncomment them:
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
  // BUSINESS FEATURES
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
    // ORDER REQUESTS
    // ----------------------------------------------------------
    orderRequests: (_) => const OrderRequestsPage(),

    // ----------------------------------------------------------
    // WASTE MANAGEMENT
    // ----------------------------------------------------------
    waste: (_) => const WasteManagementPage(),

    // ----------------------------------------------------------
    // MAINTENANCE
    // ----------------------------------------------------------

    // Enable when MaintenancePage is created.
    // maintenance: (_) => const MaintenancePage(),

    // ----------------------------------------------------------
    // REPORTS
    // ----------------------------------------------------------

    // Enable when ReportsPage is created.
    // reports: (_) => const ReportsPage(),

    // ----------------------------------------------------------
    // USER MANAGEMENT
    // ----------------------------------------------------------

    // Enable when UserManagementPage is created.
    // userManagement: (_) => const UserManagementPage(),

    // ----------------------------------------------------------
    // ADD / CREATE PAGES
    // ----------------------------------------------------------

    // Enable if AddDevicePage exists.
    // addDevice: (_) => const AddDevicePage(),

    // Enable if AddBatchPage exists.
    // addBatch: (_) => const AddBatchPage(),
  };
}
