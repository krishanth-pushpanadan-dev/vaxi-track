import 'package:flutter/material.dart';

import '../model/product_model.dart';
import 'create_order_page.dart';
import '../presentation/supplier_profile_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),

            const SizedBox(height: 20),

            _buildProductHeader(),

            const SizedBox(height: 20),

            _buildStockCard(),

            const SizedBox(height: 16),

            _buildProductInformation(),

            const SizedBox(height: 16),

            _buildStorageCard(),

            const SizedBox(height: 16),

            _buildSupplierCard(context),

            const SizedBox(height: 16),

            _buildDescription(),

            const SizedBox(height: 20),

            _buildExpiryInformation(),
          ],
        ),
      ),

      // Request button
      bottomSheet: _buildRequestButton(context),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: product.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _imagePlaceholder();
                },
              ),
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.vaccines_outlined, size: 70, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text(
          'Product Image',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            product.category,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          product.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 5),

        Text(
          product.manufacturer,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 18),
            const SizedBox(width: 7),
            Text(
              product.supplierName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockCard() {
    final bool available = product.isAvailable && !product.isExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: available ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: available ? Colors.green.shade100 : Colors.red.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: available ? Colors.green.shade100 : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              available ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: available ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  available ? 'Available in Stock' : 'Currently Unavailable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: available
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.availableQuantity} ${product.unit} available',
                  style: TextStyle(
                    fontSize: 12,
                    color: available
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInformation() {
    return _sectionCard(
      title: 'Product Information',
      icon: Icons.info_outline,
      children: [
        _detailRow('Manufacturer', product.manufacturer),
        _detailRow('Category', product.category),
        _detailRow('Unit', product.unit),
        _detailRow(
          'Minimum Order',
          '${product.minimumOrderQuantity} ${product.unit}',
        ),
        _detailRow('Price', 'Rs. ${product.price.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildStorageCard() {
    return _sectionCard(
      title: 'Storage Requirement',
      icon: Icons.thermostat_outlined,
      children: [
        Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.ac_unit_outlined, color: Colors.blue.shade700),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Temperature',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.storageTemperature,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildSupplierCard(BuildContext context) {
    return _sectionCard(
      title: 'Supplier',
      icon: Icons.business_outlined,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business_outlined,
                color: Colors.grey,
                size: 28,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.supplierName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 15, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Supplier',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                // Supplier profile will be connected
                // when the supplier page is completed.
              },
              child: const Text('View'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return _sectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      children: [
        Text(
          product.description,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryInformation() {
    final bool expired = product.isExpired;
    final bool expiringSoon = product.isExpiringSoon;

    Color backgroundColor = Colors.grey.shade50;
    Color textColor = Colors.grey.shade700;
    IconData icon = Icons.event_outlined;

    if (expired) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      icon = Icons.warning_amber_rounded;
    } else if (expiringSoon) {
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired
                      ? 'Product Expired'
                      : expiringSoon
                      ? 'Expiring Soon'
                      : 'Expiry Date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(product.expiryDate),
                  style: TextStyle(fontSize: 12, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context) {
    final bool canRequest = product.isAvailable && !product.isExpired;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: canRequest
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateOrderPage(product: product),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(canRequest ? 'Request Product' : 'Product Unavailable'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
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

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}
