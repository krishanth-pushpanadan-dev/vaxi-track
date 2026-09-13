import 'package:flutter/material.dart';

import '../model/order_request_model.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  String get _label {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';

      case OrderStatus.approved:
        return 'Approved';

      case OrderStatus.processing:
        return 'Processing';

      case OrderStatus.dispatched:
        return 'Dispatched';

      case OrderStatus.inTransit:
        return 'In Transit';

      case OrderStatus.delivered:
        return 'Delivered';

      case OrderStatus.rejected:
        return 'Rejected';

      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get _icon {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;

      case OrderStatus.approved:
        return Icons.check_circle_outline_rounded;

      case OrderStatus.processing:
        return Icons.sync_rounded;

      case OrderStatus.dispatched:
        return Icons.local_shipping_outlined;

      case OrderStatus.inTransit:
        return Icons.navigation_outlined;

      case OrderStatus.delivered:
        return Icons.done_all_rounded;

      case OrderStatus.rejected:
        return Icons.cancel_outlined;

      case OrderStatus.cancelled:
        return Icons.block_outlined;
    }
  }

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;

      case OrderStatus.approved:
        return Colors.blue;

      case OrderStatus.processing:
        return Colors.indigo;

      case OrderStatus.dispatched:
        return Colors.deepPurple;

      case OrderStatus.inTransit:
        return Colors.teal;

      case OrderStatus.delivered:
        return Colors.green;

      case OrderStatus.rejected:
        return Colors.red;

      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 14 : 16, color: color),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
