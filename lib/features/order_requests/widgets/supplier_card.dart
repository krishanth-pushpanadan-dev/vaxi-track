import 'package:flutter/material.dart';

import '../model/supplier_model.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;

  const SupplierCard({super.key, required this.supplier, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Company logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: supplier.companyLogo.isNotEmpty
                        ? Image.network(
                            supplier.companyLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _logoPlaceholder();
                            },
                          )
                        : _logoPlaceholder(),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.companyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            supplier.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (supplier.isVerified)
                  const Icon(Icons.verified, size: 20, color: Colors.blue),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              supplier.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _infoChip(
                  Icons.shopping_bag_outlined,
                  '${supplier.totalOrders} orders',
                ),
                const SizedBox(width: 8),
                _infoChip(Icons.timer_outlined, supplier.responseTime),
              ],
            ),

            const SizedBox(height: 10),

            if (supplier.coldChainCompliant)
              Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Cold Chain Compliant',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Icon(Icons.business_outlined, color: Colors.grey, size: 28),
    );
  }
}
