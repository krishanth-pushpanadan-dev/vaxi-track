import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

enum StatCardStatus { normal, success, warning, danger }

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final StatCardStatus status;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.status = StatCardStatus.normal,
    this.onTap,
  });

  Color get statusColor {
    switch (status) {
      case StatCardStatus.success:
        return Colors.green;

      case StatCardStatus.warning:
        return Colors.orange;

      case StatCardStatus.danger:
        return Colors.red;

      case StatCardStatus.normal:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    switch (status) {
      case StatCardStatus.success:
        return Colors.green.shade50;

      case StatCardStatus.warning:
        return Colors.orange.shade50;

      case StatCardStatus.danger:
        return Colors.red.shade50;

      case StatCardStatus.normal:
        return Colors.blue.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: statusColor, size: 28),
              ),

              const SizedBox(height: 20),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(Icons.circle, color: statusColor, size: 10),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
