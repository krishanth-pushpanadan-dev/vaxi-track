import 'package:flutter/material.dart';

import '../model/product_model.dart';
import '../model/supplier_model.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/supplier_card.dart';
import 'product_details_page.dart';
import 'supplier_profile_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Vaccines',
    'Medicines',
    'Syringes',
    'Cold Chain',
    'Other',
  ];

  final List<Product> _products = [
    Product(
      id: 'P001',
      name: 'Pfizer COVID-19 Vaccine',
      category: 'Vaccines',
      manufacturer: 'Pfizer',
      description:
          'Temperature-sensitive vaccine suitable for approved immunization programs.',
      imageUrl: '',
      availableQuantity: 450,
      unit: 'doses',
      minimumOrderQuantity: 20,
      price: 2500.00,
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
      description:
          'Temperature-controlled vaccine supplied for healthcare facilities.',
      imageUrl: '',
      availableQuantity: 120,
      unit: 'doses',
      minimumOrderQuantity: 10,
      price: 2800.00,
      storageTemperature: '+2°C to +8°C',
      expiryDate: DateTime(2026, 11, 18),
      supplierId: 'S002',
      supplierName: 'HealthCare Suppliers',
      isAvailable: true,
    ),
    Product(
      id: 'P003',
      name: 'Disposable Syringes',
      category: 'Syringes',
      manufacturer: 'MedEquip',
      description:
          'Sterile disposable syringes for vaccination and clinical use.',
      imageUrl: '',
      availableQuantity: 1500,
      unit: 'units',
      minimumOrderQuantity: 100,
      price: 85.00,
      storageTemperature: 'Room Temperature',
      expiryDate: DateTime(2028, 5, 30),
      supplierId: 'S003',
      supplierName: 'MediCare Lanka',
      isAvailable: true,
    ),
    Product(
      id: 'P004',
      name: 'Insulin Vial',
      category: 'Medicines',
      manufacturer: 'Novo Nordisk',
      description:
          'Temperature-sensitive pharmaceutical product requiring controlled storage.',
      imageUrl: '',
      availableQuantity: 18,
      unit: 'vials',
      minimumOrderQuantity: 5,
      price: 3200.00,
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
      manufacturer: 'Dometic',
      description:
          'Insulated cold-chain box designed for temperature-sensitive medical products.',
      imageUrl: '',
      availableQuantity: 35,
      unit: 'units',
      minimumOrderQuantity: 1,
      price: 18500.00,
      storageTemperature: 'Cold Chain',
      expiryDate: DateTime(2030, 1, 1),
      supplierId: 'S004',
      supplierName: 'ColdChain Solutions',
      isAvailable: true,
    ),
    Product(
      id: 'P006',
      name: 'Paracetamol 500mg',
      category: 'Medicines',
      manufacturer: 'State Pharmaceuticals',
      description:
          'Common pharmaceutical tablet for fever and pain management.',
      imageUrl: '',
      availableQuantity: 5000,
      unit: 'tablets',
      minimumOrderQuantity: 500,
      price: 12.00,
      storageTemperature: 'Room Temperature',
      expiryDate: DateTime(2028, 8, 15),
      supplierId: 'S003',
      supplierName: 'MediCare Lanka',
      isAvailable: true,
    ),
  ];

  final List<Supplier> _suppliers = [
    Supplier(
      id: 'S001',
      companyName: 'ABC Pharmaceuticals',
      companyLogo: '',
      description:
          'Registered pharmaceutical supplier providing vaccines and temperature-sensitive medicines.',
      address: 'Colombo, Sri Lanka',
      phone: '+94 11 234 5678',
      email: 'info@abcpharma.lk',
      rating: 4.8,
      totalOrders: 1245,
      successfulDeliveries: 1218,
      responseTime: '< 2 hrs',
      isVerified: true,
      coldChainCompliant: true,
    ),
    Supplier(
      id: 'S002',
      companyName: 'HealthCare Suppliers',
      companyLogo: '',
      description:
          'Healthcare product supplier supporting hospitals and pharmacies across Sri Lanka.',
      address: 'Kandy, Sri Lanka',
      phone: '+94 81 234 5678',
      email: 'contact@healthcare.lk',
      rating: 4.6,
      totalOrders: 865,
      successfulDeliveries: 832,
      responseTime: '< 3 hrs',
      isVerified: true,
      coldChainCompliant: true,
    ),
    Supplier(
      id: 'S003',
      companyName: 'MediCare Lanka',
      companyLogo: '',
      description:
          'Medical supplies and pharmaceutical products for healthcare facilities.',
      address: 'Gampaha, Sri Lanka',
      phone: '+94 33 234 5678',
      email: 'info@medicare.lk',
      rating: 4.5,
      totalOrders: 642,
      successfulDeliveries: 610,
      responseTime: '< 4 hrs',
      isVerified: true,
      coldChainCompliant: false,
    ),
    Supplier(
      id: 'S004',
      companyName: 'ColdChain Solutions',
      companyLogo: '',
      description:
          'Specialized cold-chain equipment and temperature-controlled logistics solutions.',
      address: 'Colombo, Sri Lanka',
      phone: '+94 11 876 5432',
      email: 'info@coldchain.lk',
      rating: 4.9,
      totalOrders: 428,
      successfulDeliveries: 420,
      responseTime: '< 1 hr',
      isVerified: true,
      coldChainCompliant: true,
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

  List<Product> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;

      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.manufacturer.toLowerCase().contains(_searchQuery) ||
          product.supplierName.toLowerCase().contains(_searchQuery) ||
          product.category.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
    );
  }

  void _openSupplier(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierProfilePage(supplier: supplier),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Supply Marketplace',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'My Requests',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(),

              const SizedBox(height: 20),

              _buildSearchBar(),

              const SizedBox(height: 24),

              _buildSectionTitle('Categories', 'Browse by category'),

              const SizedBox(height: 12),

              _buildCategories(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Verified Suppliers',
                'Trusted pharmaceutical partners',
                showSeeAll: true,
              ),

              const SizedBox(height: 12),

              _buildSuppliers(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                _selectedCategory == 'All'
                    ? 'Featured Products'
                    : _selectedCategory,
                '${_filteredProducts.length} products available',
              ),

              const SizedBox(height: 12),

              _buildProducts(),

              const SizedBox(height: 28),

              _buildBusinessInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6DBDEE), Color(0xFF4B9ED3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VaxiTrack Supply Marketplace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find vaccines, medicines and cold-chain supplies from verified suppliers.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search vaccines, medicines, suppliers...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return CategoryChip(
            label: category,
            icon: _categoryIcon(category),
            isSelected: _selectedCategory == category,
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Vaccines':
        return Icons.vaccines_outlined;
      case 'Medicines':
        return Icons.medication_outlined;
      case 'Syringes':
        return Icons.colorize_outlined;
      case 'Cold Chain':
        return Icons.ac_unit_outlined;
      case 'Other':
        return Icons.medical_services_outlined;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Widget _buildSuppliers() {
    return SizedBox(
      height: 215,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _suppliers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final supplier = _suppliers[index];

          return SupplierCard(
            supplier: supplier,
            onTap: () => _openSupplier(supplier),
          );
        },
      ),
    );
  }

  Widget _buildProducts() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No products found',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Try another search or category.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          onTap: () => _openProduct(product),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle, {
    bool showSeeAll = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        if (showSeeAll)
          TextButton(onPressed: () {}, child: const Text('See All')),
      ],
    );
  }

  Widget _buildBusinessInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 22),
              SizedBox(width: 10),
              Text(
                'Safe & Reliable Supply Chain',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Products are sourced from registered suppliers. '
            'Cold-chain requirements and product expiry information '
            'are displayed to support safe pharmaceutical procurement.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
