import 'package:flutter/material.dart';
import 'package:vaxi_track/features/authentication/models/user_model.dart';

import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/product_model.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Vaccines';
  String _selectedUnit = 'Doses';
  String _selectedTemperature = '+2°C to +8°C';
  DateTime? _expiryDate;

  bool _isAvailable = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Vaccines',
    'Medicines',
    'Syringes',
    'Cold Chain',
    'Other',
  ];

  final List<String> _units = [
    'Doses',
    'Vials',
    'Units',
    'Tablets',
    'Boxes',
    'Packets',
  ];

  final List<String> _storageTemperatures = [
    '+2°C to +8°C',
    'Room Temperature',
    'Below 0°C',
    '-20°C',
    '-70°C',
  ];

  // ============================================================
  // CURRENT USER / ROLE
  // ============================================================

  UserRole? get _currentUserRole {
    final user = AuthService().currentUser;
    return user?.role;
  }

  bool get _canAddProduct {
    final role = _currentUserRole;

    if (role == null) {
      return false;
    }

    return RolePermissions.canAddProduct(role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _quantityController.dispose();
    _minimumOrderController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ============================================================
  // ACCESS DENIED
  // ============================================================

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Add Product'), centerTitle: true),
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
                'You do not have permission to add supplier products.',
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

  // ============================================================
  // EXPIRY DATE
  // ============================================================

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    // Extra permission check.
    // This prevents unauthorized users from saving even if
    // they somehow reach this page directly.
    if (!_canAddProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to add products.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the expiry date.')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());

    final minimumOrder = int.tryParse(_minimumOrderController.text.trim());

    final price = double.tryParse(_priceController.text.trim());

    if (quantity == null || minimumOrder == null || price == null) {
      return;
    }

    if (minimumOrder > quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Minimum order quantity cannot exceed available quantity.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Temporary mock saving.
    // Firebase/backend integration will be added later.
    await Future.delayed(const Duration(milliseconds: 800));

    final product = Product(
      id: 'P-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      manufacturer: _manufacturerController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      availableQuantity: quantity,
      unit: _selectedUnit,
      minimumOrderQuantity: minimumOrder,
      price: price,
      storageTemperature: _selectedTemperature,
      expiryDate: _expiryDate!,
      supplierId: 'S001',
      supplierName: 'ABC Pharmaceuticals',
      isAvailable: _isAvailable,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully.')),
    );

    Navigator.pop(context, product);
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),

          const SizedBox(width: 8),

          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,

      filled: true,

      fillColor: Theme.of(context).colorScheme.surface,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,

      decoration: _inputDecoration(label: label, prefixIcon: icon),

      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(item.toString()));
      }).toList(),

      onChanged: onChanged,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // ROLE-BASED ACCESS CONTROL
    // ============================================================

    if (!_canAddProduct) {
      return _buildAccessDenied();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product'), centerTitle: true),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // INTRO
              // ==================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),

                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add a New Product',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Add products that pharmacies and healthcare facilities can request.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // PRODUCT INFORMATION
              // ==================================================
              _buildSectionTitle(
                'Product Information',
                Icons.medication_outlined,
              ),

              TextFormField(
                controller: _nameController,

                decoration: _inputDecoration(
                  label: 'Product Name',
                  hint: 'e.g. Pfizer COVID-19 Vaccine',
                  prefixIcon: Icons.medication_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the product name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildDropdown<String>(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                icon: Icons.category_outlined,

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _manufacturerController,

                decoration: _inputDecoration(
                  label: 'Manufacturer',
                  hint: 'e.g. Pfizer',
                  prefixIcon: Icons.factory_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the manufacturer.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,

                maxLines: 4,

                decoration: _inputDecoration(
                  label: 'Description',
                  hint: 'Enter product description...',
                  prefixIcon: Icons.description_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product description.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // PRODUCT IMAGE
              // ==================================================
              _buildSectionTitle('Product Image', Icons.image_outlined),

              TextFormField(
                controller: _imageUrlController,

                decoration: _inputDecoration(
                  label: 'Image URL',
                  hint: 'https://example.com/product-image.jpg',
                  prefixIcon: Icons.link,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'For now, use an image URL. Image upload and image processing can be connected later.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // STOCK
              // ==================================================
              _buildSectionTitle('Stock Information', Icons.inventory_outlined),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,

                      keyboardType: TextInputType.number,

                      decoration: _inputDecoration(
                        label: 'Available Quantity',
                        hint: 'e.g. 500',
                        prefixIcon: Icons.numbers,
                      ),

                      validator: (value) {
                        final quantity = int.tryParse(value?.trim() ?? '');

                        if (quantity == null || quantity <= 0) {
                          return 'Enter valid quantity.';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildDropdown<String>(
                      label: 'Unit',
                      value: _selectedUnit,
                      items: _units,
                      icon: Icons.straighten_outlined,

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _minimumOrderController,

                keyboardType: TextInputType.number,

                decoration: _inputDecoration(
                  label: 'Minimum Order Quantity',
                  hint: 'e.g. 20',
                  prefixIcon: Icons.shopping_cart_outlined,
                ),

                validator: (value) {
                  final quantity = int.tryParse(value?.trim() ?? '');

                  if (quantity == null || quantity <= 0) {
                    return 'Enter valid minimum quantity.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _priceController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: _inputDecoration(
                  label: 'Price per Unit',
                  hint: 'e.g. 2500.00',
                  prefixIcon: Icons.payments_outlined,
                ),

                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');

                  if (price == null || price <= 0) {
                    return 'Enter a valid price.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // STORAGE
              // ==================================================
              _buildSectionTitle('Storage & Expiry', Icons.ac_unit_outlined),

              _buildDropdown<String>(
                label: 'Storage Temperature',
                value: _selectedTemperature,
                items: _storageTemperatures,
                icon: Icons.thermostat_outlined,

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTemperature = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 14),

              InkWell(
                onTap: _selectExpiryDate,

                borderRadius: BorderRadius.circular(12),

                child: InputDecorator(
                  decoration: _inputDecoration(
                    label: 'Expiry Date',
                    prefixIcon: Icons.calendar_today_outlined,
                  ),

                  child: Text(
                    _expiryDate == null
                        ? 'Select expiry date'
                        : _formatDate(_expiryDate!),

                    style: TextStyle(
                      color: _expiryDate == null ? Colors.grey.shade600 : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // AVAILABILITY
              // ==================================================
              _buildSectionTitle(
                'Product Availability',
                Icons.visibility_outlined,
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),

                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,

                  title: const Text(
                    'Available for Ordering',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Text(
                    _isAvailable
                        ? 'Pharmacies can request this product.'
                        : 'Product will be hidden from ordering.',
                    style: const TextStyle(fontSize: 12),
                  ),

                  value: _isAvailable,

                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // SUPPLIER INFORMATION
              // ==================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.06),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.business_outlined),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supplier',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'ABC Pharmaceuticals',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    Icon(Icons.verified, size: 20),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // SAVE BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,

                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_business_outlined),

                  label: Text(
                    _isSaving ? 'Adding Product...' : 'Add Product',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
