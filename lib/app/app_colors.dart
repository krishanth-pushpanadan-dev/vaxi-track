import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF46A8E5);
  static const Color secondary = Color(0xFF8AD4D5);

  // Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.70, 1.0],
    colors: [
      Color(0xFF74C7F3), // Light Blue
      Color(0xFF2F97D5), // Medium Blue
      Color(0xFF005DB7), // Deep Blue
      Color(0xFF05106B), // Dark Navy
    ],
  );

  // Background
  static const Color background = Color(0xFFF7F8FA);

  // Basic Colors
  static const Color white = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFEF5350);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Border
  static const Color border = Color(0xFFE0E0E0);
}
