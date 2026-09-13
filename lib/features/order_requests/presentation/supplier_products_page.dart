import 'package:flutter/material.dart';
import 'package:vaxi_track/features/authentication/models/user_model.dart';

import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/product_model.dart';
import 'add_product_page.dart';
import 'product_details_page.dart';

class SupplierProductsPage extends StatefulWidget {
  const SupplierProductsPage({super.key});

  @override
  State<SupplierProductsPage> createState() => _SupplierProductsPageState();
}

class _SupplierProductsPageState extends State<SupplierProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Vaccines',
    'Medicines',
    'Syringes',
    'Cold Chain',
    'Other',
  ];

  // Temporary mock products.
  // Firebase product management will be connected later.
  final List<Product> _products = [
    Product(
      id: 'P001',
      name: 'Pfizer COVID-19 Vaccine',
      category: 'Vaccines',
      manufacturer: 'Pfizer',
      description: 'COVID-19 vaccine requiring controlled cold-chain storage.',
      imageUrl: '',
      availableQuantity: 450,
      unit: 'Doses',
      minimumOrderQuantity: 20,
      price: 2500,
      storageTemperature: '+2°C to +8°C',
      expiryDate: DateTime(2026, 12, 25),
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: true,
    ),
    Product(
      id: 'P002',
      name: 'Moderna Vaccine',
      category: 'Vaccines',
      manufacturer: 'Moderna',
      description: 'Vaccine product for healthcare facilities.',
      imageUrl: '',
      availableQuantity: 120,
      unit: 'Doses',
      minimumOrderQuantity: 10,
      price: 2800,
      storageTemperature: '+2°C to +8°C',
      expiryDate: DateTime(2026, 11, 18),
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: true,
    ),
    Product(
      id: 'P003',
      name: 'Disposable Syringes',
      category: 'Syringes',
      manufacturer: 'MediCare',
      description: 'Sterile disposable syringes for medical use.',
      imageUrl: '',
      availableQuantity: 1500,
      unit: 'Units',
      minimumOrderQuantity: 100,
      price: 85,
      storageTemperature: 'Room Temperature',
      expiryDate: DateTime(2028, 5, 30),
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: true,
    ),
    Product(
      id: 'P004',
      name: 'Insulin Vial',
      category: 'Medicines',
      manufacturer: 'ABC Pharmaceuticals',
      description: 'Insulin vial requiring refrigerated storage.',
      imageUrl: '',
      availableQuantity: 18,
      unit: 'Vials',
      minimumOrderQuantity: 5,
      price: 3200,
      storageTemperature: '+2°C to +8°C',
      expiryDate: DateTime(2026, 10, 20),
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: true,
    ),
    Product(
      id: 'P005',
      name: 'Medical Cold Box',
      category: 'Cold Chain',
      manufacturer: 'ColdChain Solutions',
      description: 'Insulated medical cold box for vaccine transportation.',
      imageUrl: '',
      availableQuantity: 35,
      unit: 'Units',
      minimumOrderQuantity: 1,
      price: 18500,
      storageTemperature: 'Cold Chain',
      expiryDate: DateTime(2030, 1, 1),
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: true,
    ),
    Product(
      id: 'P006',
      name: 'Paracetamol 500mg',
      category: 'Medicines',
      manufacturer: 'MediCare Lanka',
      description: 'Paracetamol 500mg tablets for general medical use.',
      imageUrl: '',
      availableQuantity: 5000,
      unit: 'Tablets',
      minimumOrderQuantity: 500,
      price: 12,
      storageTemperature: 'Room Temperature',
      expiryDate: DateTime(2028, 8, 15),
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

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

  List<Product> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery) ||
          product.manufacturer.toLowerCase().contains(_searchQuery) ||
          product.category.toLowerCase().contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get _availableProducts {
    return _products.where((product) => product.isAvailable).length;
  }

  int get _lowStockProducts {
    return _products.where((product) => product.isLowStock).length;
  }

  /// Returns the currently logged-in user's role.
  UserRole? get _currentUserRole {
    final user = AuthService().currentUser;
    return user?.role;
  }

  /// Checks whether the current user can view this page.
  bool get _canViewProducts {
    final role = _currentUserRole;

    if (role == null) {
      return false;
    }

    return RolePermissions.canViewSupplierProducts(role);
  }

  Future<void> _openAddProduct() async {
    final role = _currentUserRole;

    if (role == null || !RolePermissions.canAddProduct(role)) {
      _showAccessDenied();
      return;
    }

    final newProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    );

    if (!mounted || newProduct == null) {
      return;
    }

    setState(() {
      _products.insert(0, newProduct);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newProduct.name} added to your product list.')),
    );
  }

  void _openProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
    );
  }

  void _showAccessDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You do not have permission to perform this action.'),
      ),
    );
  }

  void _showProductOptions(Product product) {
    final role = _currentUserRole;

    if (role == null) {
      _showAccessDenied();
      return;
    }

    final canEdit = RolePermissions.canEditProduct(role);
    final canManageVisibility = RolePermissions.canManageProductVisibility(
      role,
    );

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('View Product'),
                  onTap: () {
                    Navigator.pop(context);
                    _openProductDetails(product);
                  },
                ),

                // Edit Product
                if (canEdit)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit Product'),
                    onTap: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Product editing will be connected later.',
                          ),
                        ),
                      );
                    },
                  ),

                // Hide / Show Product
                if (canManageVisibility)
                  ListTile(
                    leading: Icon(
                      product.isAvailable
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    title: Text(
                      product.isAvailable ? 'Hide Product' : 'Show Product',
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            product.isAvailable
                                ? 'Product hidden from marketplace.'
                                : 'Product shown in marketplace.',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Supplier Products'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 45,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'You do not have permission to manage supplier products.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
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
        hintText: 'Search your products...',
        prefixIcon: const Icon(Icons.search),

        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
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

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withValues(alpha: 0.15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductTile(Product product) {
    final lowStock = product.isLowStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => _openProductDetails(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Icon(
                              Icons.medication_outlined,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.medication_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => _showProductOptions(product),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.more_vert, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      product.manufacturer,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 5,
                      children: [
                        _buildSmallInfo(
                          Icons.inventory_2_outlined,
                          '${product.availableQuantity} ${product.unit}',
                        ),
                        _buildSmallInfo(
                          Icons.thermostat_outlined,
                          product.storageTemperature,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          'Rs. ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const Spacer(),

                        if (lowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Low Stock',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
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
              Icons.inventory_2_outlined,
              size: 38,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Try changing your search or category filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // ROLE-BASED ACCESS CONTROL
    // ============================================================
    if (!_canViewProducts) {
      return _buildAccessDenied();
    }

    final products = _filteredProducts;
    final role = _currentUserRole;

    final canAdd = role != null && RolePermissions.canAddProduct(role);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text('My Products'),
        centerTitle: true,
        actions: [
          if (canAdd)
            IconButton(
              onPressed: _openAddProduct,
              tooltip: 'Add Product',
              icon: const Icon(Icons.add_box_outlined),
            ),
        ],
      ),

      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: _openAddProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          setState(() {});
        },

        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            const Text(
              'Product Showcase',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              'Manage products available in your marketplace',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                _buildSummaryCard(
                  title: 'Total Products',
                  value: '${_products.length}',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),

                const SizedBox(width: 10),

                _buildSummaryCard(
                  title: 'Available',
                  value: '$_availableProducts',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),

                const SizedBox(width: 10),

                _buildSummaryCard(
                  title: 'Low Stock',
                  value: '$_lowStockProducts',
                  icon: Icons.warning_amber_outlined,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSearchBar(),

            const SizedBox(height: 14),

            _buildCategoryFilters(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Products (${products.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Marketplace',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (products.isEmpty)
              _buildEmptyState()
            else
              ...products.map(_buildProductTile),
          ],
        ),
      ),
    );
  }
}
