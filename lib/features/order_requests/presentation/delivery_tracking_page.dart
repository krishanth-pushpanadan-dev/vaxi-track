import 'dart:async';

import 'package:flutter/material.dart';

import '../model/order_request_model.dart';
import 'route_map_page.dart';

class DeliveryTrackingPage extends StatefulWidget {
  final OrderRequest order;

  const DeliveryTrackingPage({super.key, required this.order});

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  Timer? _refreshTimer;

  // Temporary mock sensor values.
  // These will later come from the ESP32/Firebase.
  double _temperature = 5.2;
  double _humidity = 61.0;
  bool _doorOpen = false;
  bool _deviceOnline = true;

  @override
  void initState() {
    super.initState();

    // Simulate live sensor updates.
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      setState(() {
        _temperature += 0.1;
        if (_temperature > 6.0) {
          _temperature = 4.8;
        }
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  bool get _isColdChainSafe {
    return _temperature >= 2 && _temperature <= 8;
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '$hour:$minute $period';
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required bool isSafe,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Spacer(),
                Icon(
                  isSafe ? Icons.check_circle : Icons.warning,
                  size: 18,
                  color: isSafe ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required bool completed,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.15),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: completed ? Colors.white : Colors.grey,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 52,
                  color: completed
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.35)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: completed ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipment In Transit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your order is currently being transported.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.green.withValues(alpha: 0.1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.green),
                SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _deviceOnline = !_deviceOnline;
              });
            },
            icon: Icon(_deviceOnline ? Icons.sync : Icons.sync_disabled),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          setState(() {
            _temperature = 5.2;
            _humidity = 61.0;
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status
              _buildStatusBanner(),

              const SizedBox(height: 22),

              // Order information
              _buildSectionTitle(
                'Shipment Information',
                Icons.inventory_2_outlined,
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow('Order ID', order.id, Icons.receipt_long_outlined),
                    const Divider(height: 24),
                    _infoRow(
                      'Tracking ID',
                      order.trackingId,
                      Icons.qr_code_2_outlined,
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      'Product',
                      order.productName,
                      Icons.medication_outlined,
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      'Quantity',
                      '${order.quantity} ${order.unit}',
                      Icons.inventory_outlined,
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      'Supplier',
                      order.supplierName,
                      Icons.business_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Live location
              _buildSectionTitle(
                'Live Delivery Location',
                Icons.location_on_outlined,
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.grey.withValues(alpha: 0.08),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 70,
                        color: Colors.grey.withValues(alpha: 0.35),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.gps_fixed, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'GPS Connected',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RouteMapPage(order: order),
                            ),
                          );
                        },
                        icon: const Icon(Icons.route_outlined),
                        label: const Text('View Route'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Current location: Kandy → Colombo',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                'GPS coordinates will be received from the ESP32 device.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              // Cold chain
              _buildSectionTitle(
                'Live Cold-Chain Monitoring',
                Icons.thermostat_outlined,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildSensorCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    value: '${_temperature.toStringAsFixed(1)}°C',
                    subtitle: 'Safe range: 2–8°C',
                    isSafe: _isColdChainSafe,
                  ),
                  const SizedBox(width: 10),
                  _buildSensorCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Humidity',
                    value: '${_humidity.toStringAsFixed(0)}%',
                    subtitle: 'Current humidity',
                    isSafe: _humidity >= 30 && _humidity <= 70,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  _buildSensorCard(
                    icon: Icons.door_front_door_outlined,
                    title: 'Container Door',
                    value: _doorOpen ? 'Open' : 'Closed',
                    subtitle: _doorOpen ? 'Check immediately' : 'Secure',
                    isSafe: !_doorOpen,
                  ),
                  const SizedBox(width: 10),
                  _buildSensorCard(
                    icon: Icons.wifi,
                    title: 'IoT Device',
                    value: _deviceOnline ? 'Online' : 'Offline',
                    subtitle: _deviceOnline
                        ? 'Live monitoring'
                        : 'Connection lost',
                    isSafe: _deviceOnline,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _isColdChainSafe
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.orange.withValues(alpha: 0.1),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isColdChainSafe ? Icons.check_circle : Icons.warning,
                      color: _isColdChainSafe ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isColdChainSafe
                            ? 'Cold-chain conditions are currently safe.'
                            : 'Temperature is outside the safe range.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Delivery progress
              _buildSectionTitle('Delivery Progress', Icons.timeline_outlined),

              const SizedBox(height: 16),

              _buildTimelineItem(
                title: 'Order Approved',
                description: 'Supplier approved your order request.',
                time: _formatDateTime(order.requestedDate),
                icon: Icons.check,
                completed: true,
              ),

              _buildTimelineItem(
                title: 'Order Processing',
                description: 'Products prepared for shipment.',
                time: '',
                icon: Icons.inventory_2_outlined,
                completed: true,
              ),

              _buildTimelineItem(
                title: 'Dispatched',
                description: 'Shipment has left the supplier.',
                time: '',
                icon: Icons.local_shipping_outlined,
                completed: true,
              ),

              _buildTimelineItem(
                title: 'In Transit',
                description: 'Shipment is currently on the way.',
                time: 'Currently active',
                icon: Icons.route_outlined,
                completed: true,
              ),

              _buildTimelineItem(
                title: 'Delivered',
                description: 'Shipment will be delivered to the destination.',
                time: order.expectedDeliveryDate != null
                    ? 'Expected: ${_formatDateTime(order.expectedDeliveryDate!)}'
                    : '',
                icon: Icons.home_outlined,
                completed: false,
                isLast: true,
              ),

              const SizedBox(height: 12),

              // Delivery destination
              _buildSectionTitle(
                'Delivery Destination',
                Icons.location_city_outlined,
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Route button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RouteMapPage(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text(
                    'View Full Delivery Route',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
