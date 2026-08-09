import 'package:flutter/material.dart';
import '../models/batch_model.dart';

class BatchCard extends StatelessWidget {
  final String vaccineName;
  final String batchNo;
  final int quantity;
  final String expiryDate;
  final String storageTemperature;
  final BatchStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onGenerateQR;

  const BatchCard({
    super.key,
    required this.vaccineName,
    required this.batchNo,
    required this.quantity,
    required this.expiryDate,
    required this.storageTemperature,
    required this.status,
    this.onTap,
    this.onGenerateQR,
  });

  Color get statusColor {
    switch (status) {
      case BatchStatus.stored:
        return Colors.green;

      case BatchStatus.transit:
        return Colors.orange;

      case BatchStatus.delivered:
        return Colors.blue;

      case BatchStatus.expired:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BatchStatus.stored:
        return Icons.inventory_2;

      case BatchStatus.transit:
        return Icons.local_shipping;

      case BatchStatus.delivered:
        return Icons.check_circle;

      case BatchStatus.expired:
        return Icons.warning;
    }
  }

  String get statusText {
    switch (status) {
      case BatchStatus.stored:
        return "Stored";

      case BatchStatus.transit:
        return "Transit";

      case BatchStatus.delivered:
        return "Delivered";

      case BatchStatus.expired:
        return "Expired";
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
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.vaccines, color: statusColor, size: 30),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccineName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Batch No : $batchNo",
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
                        Icon(statusIcon, size: 16, color: statusColor),

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
                    Icons.inventory,
                    quantity.toString(),
                    "Doses",
                    Colors.blue,
                  ),

                  _info(Icons.event, expiryDate, "Expiry", Colors.red),

                  _info(
                    Icons.ac_unit,
                    storageTemperature,
                    "Storage",
                    Colors.cyan,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),

                  const SizedBox(width: 6),

                  const Text(
                    "View Batch Details",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const Spacer(),

                  OutlinedButton.icon(
                    onPressed: onGenerateQR,
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text("QR"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                    ),
                  ),

                  const SizedBox(width: 8),

                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Open"),
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
        Icon(icon, color: color),

        const SizedBox(height: 6),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 4),

        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
