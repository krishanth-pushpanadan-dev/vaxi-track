import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

enum BatchStatus { normal, expiring, expired }

class BatchSummaryCard extends StatelessWidget {
  final String batchName;
  final String vaccineName;
  final int totalDoses;
  final int availableDoses;
  final String expiryDate;
  final BatchStatus status;
  final VoidCallback? onTap;

  const BatchSummaryCard({
    super.key,
    required this.batchName,
    required this.vaccineName,
    required this.totalDoses,
    required this.availableDoses,
    required this.expiryDate,
    this.status = BatchStatus.normal,
    this.onTap,
  });

  Color get statusColor {
    switch (status) {
      case BatchStatus.normal:
        return Colors.green;

      case BatchStatus.expiring:
        return Colors.orange;

      case BatchStatus.expired:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BatchStatus.normal:
        return Icons.check_circle;

      case BatchStatus.expiring:
        return Icons.warning;

      case BatchStatus.expired:
        return Icons.cancel;
    }
  }

  String get statusText {
    switch (status) {
      case BatchStatus.normal:
        return "ACTIVE";

      case BatchStatus.expiring:
        return "EXPIRING";

      case BatchStatus.expired:
        return "EXPIRED";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              /// Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.vaccines,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batchName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          vaccineName,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),

                        const SizedBox(width: 5),

                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(color: Colors.grey.shade300),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _info(
                    Icons.inventory_2_outlined,
                    "$totalDoses",
                    "Total",
                    Colors.blue,
                  ),

                  _info(
                    Icons.medication,
                    "$availableDoses",
                    "Available",
                    Colors.green,
                  ),

                  _info(
                    Icons.calendar_month,
                    expiryDate,
                    "Expiry",
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),

                  const SizedBox(width: 6),

                  const Expanded(
                    child: Text(
                      "Maintain cold chain storage until administration.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward_ios, size: 15),
                    label: const Text("Details"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        const SizedBox(height: 3),

        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
