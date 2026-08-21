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
  // BUSINESS FEATURES
  // ============================================================

  static const String inventory = "/dashboard/inventory";

  static const String orderRequests = "/dashboard/order-requests";

  static const String waste = "/dashboard/waste";

  static const String maintenance = "/dashboard/maintenance";

  static const String reports = "/dashboard/reports";

  static const String userManagement = "/dashboard/user-management";

  // ============================================================
  // ROUTE MAP
  // ============================================================

  static final Map<String, WidgetBuilder> routes = {
    // Authentication
    splash: (_) => const SplashPage(),

    login: (_) => const LoginPage(),

    signup: (_) => const SignupPage(),

    forgotPassword: (_) => const ForgotPasswordPage(),

    // Main
    dashboard: (_) => const DashboardPage(),

    devices: (_) => const DevicesPage(),

    batches: (_) => const BatchesPage(),

    alerts: (_) => const AlertsPage(),

    settings: (_) => const SettingsPage(),
  };
}
