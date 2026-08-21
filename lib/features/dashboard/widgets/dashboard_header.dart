import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final int notificationCount;
  final VoidCallback? onMenuPressed;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.userRole,
    this.notificationCount = 0,
    this.onMenuPressed,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  String getCurrentTime() {
    final now = DateTime.now();

    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
        ? 12
        : now.hour;

    final minute = now.minute.toString().padLeft(2, '0');

    final period = now.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 30),

      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              // ======================================================
              // MENU BUTTON
              // ======================================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.20),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: IconButton(
                  // FIX: Parent DashboardPage controls the drawer
                  onPressed: onMenuPressed,

                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              // ======================================================
              // PROFILE
              // ======================================================
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      getGreeting(),

                      style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      userName,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        userRole,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // NOTIFICATIONS
              // ======================================================
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.20),
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: IconButton(
                      onPressed: () {
                        // Alerts page can be connected here later.
                      },

                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  if (notificationCount > 0)
                    Positioned(
                      top: 5,
                      right: 5,

                      child: Container(
                        height: 18,
                        width: 18,

                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),

                        child: Center(
                          child: Text(
                            notificationCount.toString(),

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ==========================================================
          // COLD CHAIN STATUS
          // ==========================================================
          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 42,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: const [
                      Text(
                        "Cold Chain Status",

                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),

                      SizedBox(height: 5),

                      Text(
                        "All Systems Operational",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: const Text(
                    "96%",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 14),

              const SizedBox(width: 5),

              Text(
                "Last Sync ${getCurrentTime()}",

                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
