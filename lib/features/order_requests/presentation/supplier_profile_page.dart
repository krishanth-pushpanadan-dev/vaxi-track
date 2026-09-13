import 'package:flutter/material.dart';

import '../model/supplier_model.dart';
import '../model/product_model.dart';
import '../widgets/product_card.dart';
import 'product_details_page.dart';

class SupplierProfilePage extends StatefulWidget {
  final Supplier supplier;

  const SupplierProfilePage({super.key, required this.supplier});

  @override
  State<SupplierProfilePage> createState() => _SupplierProfilePageState();
}

class _SupplierProfilePageState extends State<SupplierProfilePage> {
  late final List<Product> _products;

  @override
  void initState() {
    super.initState();

    // Temporary mock products.
    // Firebase products will be loaded here later.
    _products = _buildSupplierProducts();
  }

  List<Product> _buildSupplierProducts() {
    final supplier = widget.supplier;

    return [
      Product(
        id: 'P001',
        name: 'Pfizer COVID-19 Vaccine',
        category: 'Vaccines',
        manufacturer: 'Pfizer',
        description:
            'COVID-19 vaccine requiring controlled cold-chain storage.',
        imageUrl: '',
        availableQuantity: 450,
        unit: 'Doses',
        minimumOrderQuantity: 20,
        price: 2500,
        storageTemperature: '+2°C to +8°C',
        expiryDate: DateTime(2026, 12, 25),
        supplierId: supplier.id,
        supplierName: supplier.companyName,
        isAvailable: true,
      ),
      Product(
        id: 'P002',
        name: 'Insulin Vial',
        category: 'Medicines',
        manufacturer: 'Novo Nordisk',
        description:
            'Insulin vial suitable for controlled pharmaceutical storage.',
        imageUrl: '',
        availableQuantity: 120,
        unit: 'Vials',
        minimumOrderQuantity: 5,
        price: 3200,
        storageTemperature: '+2°C to +8°C',
        expiryDate: DateTime(2026, 10, 20),
        supplierId: supplier.id,
        supplierName: supplier.companyName,
        isAvailable: true,
      ),
      Product(
        id: 'P003',
        name: 'Medical Cold Box',
        category: 'Cold Chain',
        manufacturer: 'ColdChain Medical',
        description: 'Insulated cold box designed for vaccine transportation.',
        imageUrl: '',
        availableQuantity: 35,
        unit: 'Units',
        minimumOrderQuantity: 1,
        price: 18500,
        storageTemperature: 'Cold Chain',
        expiryDate: DateTime(2030, 1, 1),
        supplierId: supplier.id,
        supplierName: supplier.companyName,
        isAvailable: true,
      ),
    ];
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(1);
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Supplier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone'),
                subtitle: Text(widget.supplier.phone),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(widget.supplier.email),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow({
    required IconData icon,
    required String title,
    required bool verified,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: verified ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Icon(icon, size: 18, color: verified ? Colors.green : Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supplier = widget.supplier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showContactDialog,
            icon: const Icon(Icons.contact_phone_outlined),
            tooltip: 'Contact Supplier',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: supplier.companyLogo.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              supplier.companyLogo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Icon(
                                  Icons.business,
                                  size: 46,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.business,
                            size: 46,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          supplier.companyName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (supplier.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 22),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(supplier.rating),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Supplier Rating',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (supplier.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 17),
                          SizedBox(width: 6),
                          Text(
                            'Verified Supplier',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.shopping_bag_outlined,
                        value: '${supplier.totalOrders}',
                        label: 'Total Orders',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        icon: Icons.local_shipping_outlined,
                        value: '${supplier.successfulDeliveries}',
                        label: 'Deliveries',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        icon: Icons.speed_outlined,
                        value: supplier.responseTime,
                        label: 'Response',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // About
                  const Text(
                    'About Supplier',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    supplier.description,
                    style: TextStyle(height: 1.5, color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 20),

                  // Contact information
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
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                supplier.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined),
                            const SizedBox(width: 12),
                            Expanded(child: Text(supplier.phone)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined),
                            const SizedBox(width: 12),
                            Expanded(child: Text(supplier.email)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Verification
                  const Text(
                    'Supplier Verification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      children: [
                        _buildVerificationRow(
                          icon: Icons.verified_outlined,
                          title: 'Supplier Verified',
                          verified: supplier.isVerified,
                        ),
                        _buildVerificationRow(
                          icon: Icons.ac_unit_outlined,
                          title: 'Cold Chain Compliant',
                          verified: supplier.coldChainCompliant,
                        ),
                        _buildVerificationRow(
                          icon: Icons.local_shipping_outlined,
                          title: 'Reliable Delivery History',
                          verified: supplier.deliverySuccessRate >= 90,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Delivery performance
                  const Text(
                    'Delivery Performance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Successful Delivery Rate',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${supplier.deliverySuccessRate.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: supplier.deliverySuccessRate / 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Products
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_products.length} products',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ..._products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Contact button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _showContactDialog,
                      icon: const Icon(Icons.contact_phone_outlined),
                      label: const Text(
                        'Contact Supplier',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
