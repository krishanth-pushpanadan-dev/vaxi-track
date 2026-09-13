import 'package:flutter/material.dart';

import '../model/order_request_model.dart';
import '../widgets/order_status_chip.dart';
import '../presentation/order_details_page.dart';

class OrderRequestsPage extends StatefulWidget {
  const OrderRequestsPage({super.key});

  @override
  State<OrderRequestsPage> createState() => _OrderRequestsPageState();
}

class _OrderRequestsPageState extends State<OrderRequestsPage> {
  final TextEditingController _searchController = TextEditingController();

  OrderStatus? _selectedStatus;
  String _searchQuery = '';

  final List<OrderRequest> _orders = [
    OrderRequest(
      id: 'ORD-1001',
      requesterId: 'PH-001',
      requesterName: 'City Care Pharmacy',
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      productId: 'P001',
      productName: 'Pfizer COVID-19 Vaccine',
      quantity: 100,
      unit: 'Doses',
      totalAmount: 250000,
      deliveryAddress: 'Peradeniya, Kandy',
      requestedDate: DateTime(2026, 9, 1),
      expectedDeliveryDate: DateTime(2026, 9, 8),
      status: OrderStatus.pending,
      notes: 'Please maintain cold-chain conditions during delivery.',
      trackingId: 'VT-458921',
    ),
    OrderRequest(
      id: 'ORD-1002',
      requesterId: 'PH-002',
      requesterName: 'Health Plus Pharmacy',
      supplierId: 'S002',
      supplierName: 'HealthCare Suppliers',
      productId: 'P002',
      productName: 'Moderna Vaccine',
      quantity: 50,
      unit: 'Doses',
      totalAmount: 140000,
      deliveryAddress: 'Katugastota, Kandy',
      requestedDate: DateTime(2026, 8, 30),
      expectedDeliveryDate: DateTime(2026, 9, 6),
      status: OrderStatus.approved,
      notes: 'Delivery required before 4 PM.',
      trackingId: 'VT-672341',
    ),
    OrderRequest(
      id: 'ORD-1003',
      requesterId: 'PH-003',
      requesterName: 'MediCare Pharmacy',
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      productId: 'P004',
      productName: 'Insulin Vial',
      quantity: 20,
      unit: 'Vials',
      totalAmount: 64000,
      deliveryAddress: 'Kandy City Centre',
      requestedDate: DateTime(2026, 8, 28),
      expectedDeliveryDate: DateTime(2026, 9, 5),
      status: OrderStatus.processing,
      notes: 'Keep refrigerated at all times.',
      trackingId: 'VT-894215',
    ),
    OrderRequest(
      id: 'ORD-1004',
      requesterId: 'PH-004',
      requesterName: 'Family Health Pharmacy',
      supplierId: 'S004',
      supplierName: 'ColdChain Solutions',
      productId: 'P005',
      productName: 'Medical Cold Box',
      quantity: 5,
      unit: 'Units',
      totalAmount: 92500,
      deliveryAddress: 'Matale Road, Kandy',
      requestedDate: DateTime(2026, 8, 25),
      expectedDeliveryDate: DateTime(2026, 9, 3),
      status: OrderStatus.dispatched,
      notes: 'Handle carefully during transportation.',
      trackingId: 'VT-315784',
    ),
    OrderRequest(
      id: 'ORD-1005',
      requesterId: 'PH-005',
      requesterName: 'Central Medical Centre',
      supplierId: 'S003',
      supplierName: 'MediCare Lanka',
      productId: 'P006',
      productName: 'Paracetamol 500mg',
      quantity: 1000,
      unit: 'Tablets',
      totalAmount: 12000,
      deliveryAddress: 'Gampola, Kandy',
      requestedDate: DateTime(2026, 8, 20),
      expectedDeliveryDate: DateTime(2026, 8, 25),
      status: OrderStatus.delivered,
      notes: 'Standard delivery.',
      trackingId: 'VT-241963',
    ),
    OrderRequest(
      id: 'ORD-1006',
      requesterId: 'PH-006',
      requesterName: 'Green Cross Pharmacy',
      supplierId: 'S002',
      supplierName: 'HealthCare Suppliers',
      productId: 'P002',
      productName: 'Moderna Vaccine',
      quantity: 30,
      unit: 'Doses',
      totalAmount: 84000,
      deliveryAddress: 'Nawalapitiya, Kandy',
      requestedDate: DateTime(2026, 8, 18),
      expectedDeliveryDate: DateTime(2026, 8, 24),
      status: OrderStatus.rejected,
      notes: 'Requested quantity was unavailable.',
      trackingId: 'VT-729541',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderRequest> get _filteredOrders {
    return _orders.where((order) {
      final matchesSearch =
          order.id.toLowerCase().contains(_searchQuery) ||
          order.productName.toLowerCase().contains(_searchQuery) ||
          order.supplierName.toLowerCase().contains(_searchQuery) ||
          order.requesterName.toLowerCase().contains(_searchQuery) ||
          order.trackingId.toLowerCase().contains(_searchQuery);

      final matchesStatus =
          _selectedStatus == null || order.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int _statusCount(OrderStatus status) {
    return _orders.where((order) => order.status == status).length;
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

  void _openOrderDetails(OrderRequest order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailsPage(order: order)),
    );
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search orders, products, suppliers...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.clear),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'All',
            count: _orders.length,
            selected: _selectedStatus == null,
            onTap: () {
              setState(() {
                _selectedStatus = null;
              });
            },
          ),
          _buildFilterChip(
            label: 'Pending',
            count: _statusCount(OrderStatus.pending),
            selected: _selectedStatus == OrderStatus.pending,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.pending;
              });
            },
          ),
          _buildFilterChip(
            label: 'Approved',
            count: _statusCount(OrderStatus.approved),
            selected: _selectedStatus == OrderStatus.approved,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.approved;
              });
            },
          ),
          _buildFilterChip(
            label: 'Processing',
            count: _statusCount(OrderStatus.processing),
            selected: _selectedStatus == OrderStatus.processing,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.processing;
              });
            },
          ),
          _buildFilterChip(
            label: 'Dispatched',
            count: _statusCount(OrderStatus.dispatched),
            selected: _selectedStatus == OrderStatus.dispatched,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.dispatched;
              });
            },
          ),
          _buildFilterChip(
            label: 'In Transit',
            count: _statusCount(OrderStatus.inTransit),
            selected: _selectedStatus == OrderStatus.inTransit,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.inTransit;
              });
            },
          ),
          _buildFilterChip(
            label: 'Delivered',
            count: _statusCount(OrderStatus.delivered),
            selected: _selectedStatus == OrderStatus.delivered,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.delivered;
              });
            },
          ),
          _buildFilterChip(
            label: 'Rejected',
            count: _statusCount(OrderStatus.rejected),
            selected: _selectedStatus == OrderStatus.rejected,
            onTap: () {
              setState(() {
                _selectedStatus = OrderStatus.rejected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? primaryColor
                  : Colors.grey.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.20)
                      : Colors.grey.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderRequest order) {
    return InkWell(
      onTap: () => _openOrderDetails(order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Order ID + status
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                OrderStatusChip(status: order.status, compact: true),
              ],
            ),

            const SizedBox(height: 14),

            // Product
            Text(
              order.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 15,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    order.supplierName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Quantity + total
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Quantity',
                    value: '${order.quantity} ${order.unit}',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.payments_outlined,
                    label: 'Total',
                    value: 'Rs. ${order.totalAmount.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Date + tracking
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(order.requestedDate),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      order.trackingId,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // View details
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey.shade600),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                value,
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

  Widget _buildEmptyState() {
    final hasFilters = _searchQuery.isNotEmpty || _selectedStatus != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilters ? 'No orders found' : 'No order requests yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try changing your search or filters.'
                  : 'Your product requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order data refreshed.')),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            // Header
            const Text(
              'Order Requests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              'Track and manage your product orders',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 18),

            // Summary cards
            Row(
              children: [
                _buildSummaryCard(
                  title: 'Total Orders',
                  value: '${_orders.length}',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildSummaryCard(
                  title: 'Pending',
                  value: '${_statusCount(OrderStatus.pending)}',
                  icon: Icons.hourglass_empty_rounded,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildSummaryCard(
                  title: 'Delivered',
                  value: '${_statusCount(OrderStatus.delivered)}',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search
            _buildSearchBar(),

            const SizedBox(height: 14),

            // Status filters
            _buildStatusFilter(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders (${filteredOrders.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedStatus != null)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (filteredOrders.isEmpty)
              _buildEmptyState()
            else
              ...filteredOrders.map(_buildOrderCard),
          ],
        ),
      ),
    );
  }
}
