import 'package:flutter/material.dart';

import '../model/product_model.dart';
import '../model/order_request_model.dart';

class CreateOrderPage extends StatefulWidget {
  final Product product;

  const CreateOrderPage({super.key, required this.product});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  DateTime? _deliveryDate;
  bool _isSubmitting = false;

  Product get product => widget.product;

  int get quantity {
    return int.tryParse(_quantityController.text.trim()) ?? 0;
  }

  double get totalAmount {
    return quantity * product.price;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select required delivery date',
    );

    if (pickedDate != null) {
      setState(() {
        _deliveryDate = pickedDate;
      });
    }
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

  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD-${timestamp.toString().substring(5)}';
  }

  String _generateTrackingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'VT-${timestamp.toString().substring(6)}';
  }

  Future<void> _submitOrder() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a required delivery date.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Temporary mock saving.
    // Firebase/API integration will be added later.
    await Future.delayed(const Duration(milliseconds: 800));

    final order = OrderRequest(
      id: _generateOrderId(),
      requesterId: 'DEMO_USER',
      requesterName: 'Demo Pharmacy',
      supplierId: product.supplierId,
      supplierName: product.supplierName,
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unit: product.unit,
      totalAmount: totalAmount,
      deliveryAddress: _addressController.text.trim(),
      requestedDate: DateTime.now(),
      expectedDeliveryDate: _deliveryDate,
      status: OrderStatus.pending,
      notes: _notesController.text.trim(),
      trackingId: _generateTrackingId(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order request submitted successfully.')),
    );

    Navigator.pop(context, order);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
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
                          Icons.vaccines_outlined,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.vaccines_outlined,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.manufacturer,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  'Supplier: ${product.supplierName}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs. ${product.price.toStringAsFixed(2)} / ${product.unit}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Quantity',
        hintText: 'Enter quantity',
        prefixIcon: const Icon(Icons.inventory_2_outlined),
        suffixText: product.unit,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (_) {
        setState(() {});
      },
      validator: (value) {
        final enteredQuantity = int.tryParse(value?.trim() ?? '');

        if (enteredQuantity == null || enteredQuantity <= 0) {
          return 'Enter a valid quantity';
        }

        if (enteredQuantity < product.minimumOrderQuantity) {
          return 'Minimum order is ${product.minimumOrderQuantity} ${product.unit}';
        }

        if (enteredQuantity > product.availableQuantity) {
          return 'Only ${product.availableQuantity} ${product.unit} available';
        }

        return null;
      },
    );
  }

  Widget _buildDeliveryDateField() {
    return InkWell(
      onTap: _selectDeliveryDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Required Delivery Date',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _deliveryDate == null
              ? 'Select delivery date'
              : _formatDate(_deliveryDate!),
          style: TextStyle(
            color: _deliveryDate == null
                ? Colors.grey.shade600
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStorageRequirement() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.thermostat_outlined, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storage / Temperature Requirement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  product.storageTemperature,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Unit Price'),
              Text('Rs. ${product.price.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity'),
              Text('$quantity ${product.unit}'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. ${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Request Product'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductSummary(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Order Quantity',
                Icons.shopping_cart_outlined,
              ),

              const SizedBox(height: 12),

              _buildQuantityField(),

              const SizedBox(height: 8),

              Text(
                'Minimum order: ${product.minimumOrderQuantity} ${product.unit} • '
                'Available: ${product.availableQuantity} ${product.unit}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Delivery Information',
                Icons.local_shipping_outlined,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter pharmacy / facility delivery address',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 42),
                    child: Icon(Icons.location_on_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a delivery address';
                  }

                  if (value.trim().length < 10) {
                    return 'Please enter a valid delivery address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildDeliveryDateField(),

              const SizedBox(height: 16),

              _buildStorageRequirement(),

              const SizedBox(height: 24),

              _buildSectionTitle('Special Instructions', Icons.notes_outlined),

              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText:
                      'Add any special delivery or handling instructions...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Order Summary', Icons.receipt_long_outlined),

              const SizedBox(height: 12),

              _buildOrderSummary(),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text(
                      'Submit Order Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
