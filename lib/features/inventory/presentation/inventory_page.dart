import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/inventory_item_model.dart';
import '../widgets/inventory_item_card.dart';
import '../presentation/add_stock_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // ------------------------------------------------------------
  // Temporary data
  //
  // Later this will come from Firebase.
  // ------------------------------------------------------------

  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      id: 'INV001',
      vaccineName: 'Pfizer COVID-19',
      batchNumber: 'PF-2026-102',
      totalDoses: 1200,
      availableDoses: 980,
      expiryDate: DateTime(2026, 8, 18),
      storageLocation: 'Cold Room A',
    ),
    InventoryItem(
      id: 'INV002',
      vaccineName: 'BCG Vaccine',
      batchNumber: 'BCG-2026-021',
      totalDoses: 800,
      availableDoses: 120,
      expiryDate: DateTime(2026, 10, 30),
      storageLocation: 'Cold Room B',
    ),
    InventoryItem(
      id: 'INV003',
      vaccineName: 'MMR Vaccine',
      batchNumber: 'MMR-2026-031',
      totalDoses: 650,
      availableDoses: 0,
      expiryDate: DateTime(2026, 7, 14),
      storageLocation: 'Cold Room C',
    ),
    InventoryItem(
      id: 'INV004',
      vaccineName: 'Hepatitis B Vaccine',
      batchNumber: 'HB-2026-014',
      totalDoses: 500,
      availableDoses: 420,
      expiryDate: DateTime(2026, 9, 13),
      storageLocation: 'Cold Room A',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Permission
  // ------------------------------------------------------------

  bool get _canViewInventory {
    final user = _authService.currentUser;

    if (user == null) return false;

    return RolePermissions.canViewInventory(user.role);
  }

  bool get _canAddInventory {
    final user = _authService.currentUser;

    if (user == null) return false;

    return RolePermissions.canAddInventory(user.role);
  }

  // ------------------------------------------------------------
  // Filter
  // ------------------------------------------------------------

  List<InventoryItem> get _filteredItems {
    if (_searchQuery.trim().isEmpty) {
      return _inventoryItems;
    }

    final query = _searchQuery.toLowerCase();

    return _inventoryItems.where((item) {
      return item.vaccineName.toLowerCase().contains(query) ||
          item.batchNumber.toLowerCase().contains(query) ||
          item.storageLocation.toLowerCase().contains(query);
    }).toList();
  }

  // ------------------------------------------------------------
  // Statistics
  // ------------------------------------------------------------

  int get _availableDoses {
    return _inventoryItems.fold(0, (sum, item) => sum + item.availableDoses);
  }

  int get _lowStockCount {
    return _inventoryItems.where((item) {
      return item.isLowStock && !item.isOutOfStock;
    }).length;
  }

  int get _outOfStockCount {
    return _inventoryItems.where((item) {
      return item.isOutOfStock;
    }).length;
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!_canViewInventory) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inventory')),
        body: const Center(
          child: Text('You do not have permission to access inventory.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInventory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              _buildSummary(),

              const SizedBox(height: 25),

              _buildSearch(),

              const SizedBox(height: 20),

              _buildInventoryList(),
            ],
          ),
        ),
      ),
      floatingActionButton: _canAddInventory
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: _addInventory,
              icon: const Icon(Icons.add),
              label: const Text('Add Stock'),
            )
          : null,
    );
  }

  // ------------------------------------------------------------
  // Header
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vaccine Inventory',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Monitor vaccine stock and storage availability.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Summary
  // ------------------------------------------------------------

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.vaccines_rounded,
            value: _availableDoses.toString(),
            label: 'Available Doses',
            iconColor: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.warning_amber_rounded,
            value: _lowStockCount.toString(),
            label: 'Low Stock',
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.error_outline_rounded,
            value: _outOfStockCount.toString(),
            label: 'Out of Stock',
            iconColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 27),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Search
  // ------------------------------------------------------------

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search vaccine, batch or storage...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // ------------------------------------------------------------
  // Inventory list
  // ------------------------------------------------------------

  Widget _buildInventoryList() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No inventory found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Try a different search term.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Stock Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${items.length} items',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...items.map(
          (item) => InventoryItemCard(
            item: item,
            onTap: () {
              _showItemDetails(item);
            },
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Details
  // ------------------------------------------------------------

  void _showItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.vaccineName,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Batch: ${item.batchNumber}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _detailRow('Total Doses', item.totalDoses.toString()),

              _detailRow('Available Doses', item.availableDoses.toString()),

              // FIX:
              // expiryDate is DateTime, so format it instead
              // of casting it to String.
              _detailRow('Expiry Date', _formatDate(item.expiryDate)),

              _detailRow('Storage Location', item.storageLocation),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Date formatter
  // ------------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} '
        '${date.year}';
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  // ------------------------------------------------------------
  // Detail row
  // ------------------------------------------------------------

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Add inventory
  // ------------------------------------------------------------

  Future<void> _addInventory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddStockPage()),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock added successfully.')),
      );
    }
  }

  // ------------------------------------------------------------
  // Refresh
  // ------------------------------------------------------------

  Future<void> _refreshInventory() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Inventory refreshed')));
  }
}
