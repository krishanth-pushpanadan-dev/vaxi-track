import 'package:flutter/material.dart';

import '../features/splash/presentation/splash_page.dart';
import '../features/authentication/presentation/login_page.dart';
import '../features/authentication/presentation/signup_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/authentication/presentation/forgot_password_page.dart';
import '../features/devices/presentation/devices_page.dart';
import '../features/vaccine_batches/presentation/batches_page.dart';
import '../features/alerts/presentation/alerts_page.dart';
import '../features/settings/presentation/settings_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/";
  static const String login = "/login";
  static const String signup = "/signup";
  static const String dashboard = "/dashboard";
  static const String forgotPassword = "/forgot-password";
  static const String devices = "/dashboard/devices";
  static const String batches = "/dashboard/batches";
  static const String alerts = "/dashboard/alerts";
  static const String settings = "/dashboard/settings";

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    signup: (_) => const SignupPage(),
    dashboard: (_) => const DashboardPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    devices: (_) => const DevicesPage(),
    batches: (_) => const BatchesPage(),
    alerts: (_) => const AlertsPage(),
    settings: (_) => const SettingsPage(),
  };
}
