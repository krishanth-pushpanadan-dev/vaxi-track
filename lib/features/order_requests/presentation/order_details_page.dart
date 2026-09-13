import 'package:flutter/material.dart';

import '../model/order_request_model.dart';
import '../widgets/order_status_chip.dart';
import '../presentation/delivery_tracking_page.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderRequest order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late OrderStatus _currentStatus;

  OrderRequest get order => widget.order;

  @override
  void initState() {
    super.initState();
    _currentStatus = order.status;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _statusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Request Submitted';

      case OrderStatus.approved:
        return 'Order Approved';

      case OrderStatus.processing:
        return 'Order Being Processed';

      case OrderStatus.dispatched:
        return 'Order Dispatched';

      case OrderStatus.inTransit:
        return 'Order In Transit';

      case OrderStatus.delivered:
        return 'Order Delivered';

      case OrderStatus.rejected:
        return 'Order Rejected';

      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  String _statusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for the supplier to review your request.';

      case OrderStatus.approved:
        return 'The supplier has approved your order request.';

      case OrderStatus.processing:
        return 'The supplier is preparing your order.';

      case OrderStatus.dispatched:
        return 'Your order has been dispatched for delivery.';

      case OrderStatus.inTransit:
        return 'Your order is currently being transported.';

      case OrderStatus.delivered:
        return 'Your order has been successfully delivered.';

      case OrderStatus.rejected:
        return 'The supplier has rejected this order request.';

      case OrderStatus.cancelled:
        return 'This order request has been cancelled.';
    }
  }

  Color _statusColor(OrderStatus status) {
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

  int _statusStep(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;

      case OrderStatus.approved:
        return 1;

      case OrderStatus.processing:
        return 2;

      case OrderStatus.dispatched:
        return 3;

      case OrderStatus.inTransit:
        return 4;

      case OrderStatus.delivered:
        return 5;

      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get _canCancel {
    return _currentStatus == OrderStatus.pending ||
        _currentStatus == OrderStatus.approved;
  }

  bool get _canTrack {
    return _currentStatus == OrderStatus.dispatched ||
        _currentStatus == OrderStatus.inTransit;
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order?'),
          content: const Text(
            'Are you sure you want to cancel this order request? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Order'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // Temporary local/mock update.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _currentStatus = OrderStatus.cancelled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order cancelled successfully.')),
    );
  }

  void _trackDelivery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeliveryTrackingPage(order: order)),
    );
  }

  Widget _buildStatusHeader() {
    final color = _statusColor(_currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(_currentStatus), color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            _statusTitle(_currentStatus),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _statusDescription(_currentStatus),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          OrderStatusChip(status: _currentStatus),
        ],
      ),
    );
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;

      case OrderStatus.approved:
        return Icons.check_circle_outline_rounded;

      case OrderStatus.processing:
        return Icons.inventory_2_outlined;

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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildProductInformation() {
    return Column(
      children: [
        _buildDetailRow(
          'Product',
          order.productName,
          Icons.medication_outlined,
        ),
        _buildDetailRow(
          'Supplier',
          order.supplierName,
          Icons.business_outlined,
        ),
        _buildDetailRow(
          'Quantity',
          '${order.quantity} ${order.unit}',
          Icons.inventory_2_outlined,
        ),
        _buildDetailRow(
          'Total Amount',
          'Rs. ${order.totalAmount.toStringAsFixed(2)}',
          Icons.payments_outlined,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildDeliveryInformation() {
    return Column(
      children: [
        _buildDetailRow(
          'Delivery Address',
          order.deliveryAddress,
          Icons.location_on_outlined,
        ),
        _buildDetailRow(
          'Requested Date',
          _formatDate(order.requestedDate),
          Icons.calendar_today_outlined,
        ),
        if (order.expectedDeliveryDate != null)
          _buildDetailRow(
            'Required By',
            _formatDate(order.expectedDeliveryDate!),
            Icons.event_available_outlined,
            isLast: true,
          )
        else
          const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildTrackingInformation() {
    return Column(
      children: [
        _buildDetailRow('Order ID', order.id, Icons.receipt_long_outlined),
        _buildDetailRow(
          'Tracking ID',
          order.trackingId,
          Icons.qr_code_2,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final currentStep = _statusStep(_currentStatus);

    if (currentStep == -1) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _statusColor(_currentStatus).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _statusIcon(_currentStatus),
              color: _statusColor(_currentStatus),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _statusDescription(_currentStatus),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      (
        OrderStatus.pending,
        'Request Submitted',
        'Your order request was submitted.',
      ),
      (OrderStatus.approved, 'Approved', 'Supplier approved the order.'),
      (OrderStatus.processing, 'Processing', 'Order is being prepared.'),
      (
        OrderStatus.dispatched,
        'Dispatched',
        'Order was handed over for delivery.',
      ),
      (
        OrderStatus.inTransit,
        'In Transit',
        'Order is currently being transported.',
      ),
      (
        OrderStatus.delivered,
        'Delivered',
        'Order has reached the destination.',
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final completed = index <= currentStep;
        final active = index == currentStep;

        return _buildTimelineItem(
          title: step.$2,
          description: step.$3,
          completed: completed,
          active: active,
          isLast: index == steps.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required bool completed,
    required bool active,
    required bool isLast,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: completed ? primaryColor : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed ? Icons.check : Icons.circle,
                  size: completed ? 15 : 7,
                  color: completed ? Colors.white : Colors.grey.shade500,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  color: completed
                      ? primaryColor.withValues(alpha: 0.35)
                      : Colors.grey.shade200,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        order.notes.isEmpty
            ? 'No special instructions were provided.'
            : order.notes,
        style: TextStyle(
          color: order.notes.isEmpty
              ? Colors.grey.shade500
              : Colors.grey.shade700,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_canTrack && !_canCancel) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (_canTrack)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _trackDelivery,
              icon: const Icon(Icons.location_searching_outlined),
              label: const Text(
                'Track Delivery',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        if (_canTrack && _canCancel) const SizedBox(height: 10),
        if (_canCancel)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _cancelOrder,
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text(
                'Cancel Order',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Order Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),

            const SizedBox(height: 18),

            _buildSectionCard(
              title: 'Order Information',
              icon: Icons.shopping_bag_outlined,
              child: _buildProductInformation(),
            ),

            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Delivery Information',
              icon: Icons.local_shipping_outlined,
              child: _buildDeliveryInformation(),
            ),

            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Tracking Information',
              icon: Icons.location_searching_outlined,
              child: _buildTrackingInformation(),
            ),

            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Order Progress',
              icon: Icons.timeline_outlined,
              child: _buildStatusTimeline(),
            ),

            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Special Instructions',
              icon: Icons.notes_outlined,
              child: _buildNotes(),
            ),

            const SizedBox(height: 20),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}
