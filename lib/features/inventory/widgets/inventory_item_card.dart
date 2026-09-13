import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../model/inventory_item_model.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;

  const InventoryItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool outOfStock = item.isOutOfStock;
    final bool lowStock = item.isLowStock;

    final Color statusColor;

    if (outOfStock) {
      statusColor = Colors.red;
    } else if (lowStock) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    final String statusText;

    if (outOfStock) {
      statusText = 'Out of Stock';
    } else if (lowStock) {
      statusText = 'Low Stock';
    } else {
      statusText = 'In Stock';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // Vaccine name + status
                // ------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.vaccines_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.vaccineName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Batch: ${item.batchNumber}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // Available doses
                // ------------------------------------------------
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Available',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),

                    const Spacer(),

                    Text(
                      '${item.availableDoses} / ${item.totalDoses} doses',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                // ------------------------------------------------
                // Stock progress
                // ------------------------------------------------
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.stockPercentage.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),

                const SizedBox(height: 16),

                // ------------------------------------------------
                // Details
                // ------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _detailItem(
                        icon: Icons.event_outlined,
                        label: 'Expiry',
                        value: _formatDate(item.expiryDate),
                      ),
                    ),

                    Expanded(
                      child: _detailItem(
                        icon: Icons.location_on_outlined,
                        label: 'Storage',
                        value: item.storageLocation,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------
                // View button
                // ------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'View Details',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.grey),

        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
