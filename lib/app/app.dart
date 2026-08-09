import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'app_theme.dart';

class VaxiTrackApp extends StatelessWidget {
  const VaxiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VaxiTrack Sri Lanka",
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
