import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            // 0 - Home
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Home",
            ),

            // 1 - Devices
            BottomNavigationBarItem(
              icon: Icon(Icons.memory_rounded),
              label: "Devices",
            ),

            // 2 - Vaccine Batches
            BottomNavigationBarItem(
              icon: Icon(Icons.vaccines_rounded),
              label: "Batches",
            ),

            // 3 - Alerts
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_rounded),
              label: "Alerts",
            ),
          ],
        ),
      ),
    );
  }
}
