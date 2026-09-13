import 'package:flutter/material.dart';

import '../model/order_request_model.dart';

class RouteMapPage extends StatefulWidget {
  final OrderRequest order;

  const RouteMapPage({super.key, required this.order});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  bool _showDetails = true;

  // Temporary mock route information.
  // Real GPS coordinates will come from the ESP32 later.
  final List<_RoutePoint> _routePoints = const [
    _RoutePoint(
      name: 'Supplier Warehouse',
      location: 'Kandy',
      icon: Icons.warehouse_outlined,
      completed: true,
    ),
    _RoutePoint(
      name: 'Current Location',
      location: 'Kadawatha',
      icon: Icons.local_shipping_outlined,
      completed: false,
      isCurrent: true,
    ),
    _RoutePoint(
      name: 'Delivery Destination',
      location: 'Colombo',
      icon: Icons.local_pharmacy_outlined,
      completed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Route'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            icon: Icon(_showDetails ? Icons.info_outline : Icons.info),
            tooltip: 'Route Details',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mock map area
          Positioned.fill(child: _buildMockMap()),

          // GPS status
          Positioned(top: 16, left: 16, right: 16, child: _buildGpsStatus()),

          // Route information panel
          if (_showDetails)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _buildRoutePanel(order),
            ),
        ],
      ),
    );
  }

  Widget _buildMockMap() {
    return Container(
      color: Colors.grey.shade100,
      child: CustomPaint(
        painter: _RoutePainter(
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
        child: Stack(
          children: [
            // Supplier marker
            Positioned(
              left: 45,
              top: 210,
              child: _buildMapMarker(
                icon: Icons.warehouse_outlined,
                label: 'Kandy',
                active: false,
              ),
            ),

            // Current vehicle marker
            Positioned(
              left: 165,
              top: 325,
              child: _buildMapMarker(
                icon: Icons.local_shipping,
                label: 'Vehicle',
                active: true,
              ),
            ),

            // Destination marker
            Positioned(
              right: 45,
              bottom: 210,
              child: _buildMapMarker(
                icon: Icons.local_pharmacy_outlined,
                label: 'Colombo',
                active: false,
              ),
            ),

            // Mock road labels
            Positioned(
              top: 145,
              left: 80,
              child: Transform.rotate(
                angle: -0.25,
                child: _mapLabel('Kandy Road'),
              ),
            ),

            Positioned(
              top: 440,
              left: 120,
              child: Transform.rotate(
                angle: 0.15,
                child: _mapLabel('A1 Highway'),
              ),
            ),

            Positioned(right: 55, top: 250, child: _mapLabel('Colombo')),
          ],
        ),
      ),
    );
  }

  Widget _mapLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildMapMarker({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: active ? 48 : 42,
          height: active ? 48 : 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: active ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: active ? 25 : 21,
            color: active
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildGpsStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withValues(alpha: 0.1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'GPS tracking active',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePanel(OrderRequest order) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 390),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Delivery Route',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 7, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              'Order ${order.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 18),

            // Route points
            ...List.generate(_routePoints.length, (index) {
              final point = _routePoints[index];

              return _buildRoutePoint(
                point,
                isLast: index == _routePoints.length - 1,
              );
            }),

            const SizedBox(height: 8),

            // Distance and ETA
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _routeStat(
                      Icons.route_outlined,
                      'Distance',
                      '112 km',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _routeStat(
                      Icons.access_time_outlined,
                      'Estimated Arrival',
                      'Today, 3:30 PM',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Cold chain indicator
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(Icons.thermostat_outlined, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cold-chain conditions are within the safe range.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.check_circle, size: 19, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePoint(_RoutePoint point, {required bool isLast}) {
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
                  color: point.isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : point.completed
                      ? Colors.green
                      : Colors.grey.withValues(alpha: 0.2),
                ),
                child: Icon(
                  point.icon,
                  size: 16,
                  color: point.isCurrent || point.completed
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 42,
                  color: point.completed
                      ? Colors.green.withValues(alpha: 0.35)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      point.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: point.isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    if (point.isCurrent) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NOW',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  point.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _routeStat(IconData icon, String title, String value) {
    return Row(
      children: [
        const SizedBox(width: 5),
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoutePoint {
  final String name;
  final String location;
  final IconData icon;
  final bool completed;
  final bool isCurrent;

  const _RoutePoint({
    required this.name,
    required this.location,
    required this.icon,
    required this.completed,
    this.isCurrent = false,
  });
}

class _RoutePainter extends CustomPainter {
  final Color primaryColor;

  _RoutePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Mock roads
    final road1 = Path()
      ..moveTo(0, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.38,
        size.width,
        size.height * 0.25,
      );

    final road2 = Path()
      ..moveTo(size.width * 0.10, size.height)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.60,
        size.width * 0.85,
        0,
      );

    canvas.drawPath(road1, roadPaint);
    canvas.drawPath(road2, roadPaint);

    // Main delivery route
    final route = Path()
      ..moveTo(size.width * 0.16, size.height * 0.43)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.48,
        size.width * 0.43,
        size.height * 0.58,
        size.width * 0.56,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.69,
        size.width * 0.77,
        size.height * 0.72,
        size.width * 0.86,
        size.height * 0.82,
      );

    canvas.drawPath(route, routePaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor;
  }
}
