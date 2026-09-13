import 'package:flutter/material.dart';
import 'package:vaxi_track/features/authentication/models/user_model.dart';

import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/product_model.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumOrderController;
  late final TextEditingController _priceController;

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
    'Bottles',
    'Packets',
  ];

  final List<String> _storageOptions = [
    'Room Temperature',
    '+2°C to +8°C',
    '-20°C',
    '-70°C',
    'Cold Chain',
  ];

  late String _selectedCategory;
  late String _selectedUnit;
  late String _selectedStorage;
  late DateTime _selectedExpiryDate;
  late bool _isAvailable;

  bool _isSaving = false;

  // ============================================================
  // CURRENT USER ROLE
  // ============================================================

  UserRole? get _currentUserRole {
    final user = AuthService().currentUser;
    return user?.role;
  }

  bool get _canEditProduct {
    final role = _currentUserRole;

    if (role == null) {
      return false;
    }

    return RolePermissions.canEditProduct(role);
  }

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product.name);
    _manufacturerController = TextEditingController(text: product.manufacturer);
    _descriptionController = TextEditingController(text: product.description);
    _imageUrlController = TextEditingController(text: product.imageUrl);
    _quantityController = TextEditingController(
      text: product.availableQuantity.toString(),
    );
    _minimumOrderController = TextEditingController(
      text: product.minimumOrderQuantity.toString(),
    );
    _priceController = TextEditingController(text: product.price.toString());

    _selectedCategory = product.category;
    _selectedUnit = product.unit;
    _selectedStorage = product.storageTemperature;
    _selectedExpiryDate = product.expiryDate;
    _isAvailable = product.isAvailable;

    // Make sure old/mock values not present in dropdown options
    // don't cause a DropdownButton assertion.
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }

    if (!_units.contains(_selectedUnit)) {
      _units.add(_selectedUnit);
    }

    if (!_storageOptions.contains(_selectedStorage)) {
      _storageOptions.add(_selectedStorage);
    }
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
      appBar: AppBar(title: const Text('Edit Product'), centerTitle: true),
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
                'You do not have permission to edit products.',
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
  // DATE PICKER
  // ============================================================

  Future<void> _selectExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate.isBefore(DateTime.now())
          ? DateTime.now()
          : _selectedExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedExpiryDate = pickedDate;
    });
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    if (!_canEditProduct) {
      _showAccessDenied();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());

    final minimumOrderQuantity = int.tryParse(
      _minimumOrderController.text.trim(),
    );

    final price = double.tryParse(_priceController.text.trim());

    if (quantity == null || minimumOrderQuantity == null || price == null) {
      _showError('Please enter valid numeric values.');
      return;
    }

    if (quantity < 0) {
      _showError('Available quantity cannot be negative.');
      return;
    }

    if (minimumOrderQuantity <= 0) {
      _showError('Minimum order quantity must be greater than 0.');
      return;
    }

    if (minimumOrderQuantity > quantity) {
      _showError(
        'Minimum order quantity cannot be greater than available quantity.',
      );
      return;
    }

    if (price <= 0) {
      _showError('Price must be greater than 0.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Temporary mock delay.
    // Firebase/database update will be connected later.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) {
      return;
    }

    final updatedProduct = widget.product.copyWith(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      manufacturer: _manufacturerController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      availableQuantity: quantity,
      unit: _selectedUnit,
      minimumOrderQuantity: minimumOrderQuantity,
      price: price,
      storageTemperature: _selectedStorage,
      expiryDate: _selectedExpiryDate,
      isAvailable: _isAvailable,
    );

    Navigator.pop(context, updatedProduct);
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAccessDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You do not have permission to edit products.'),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // EXPIRY DATE
  // ============================================================

  Widget _buildExpiryDate() {
    return InkWell(
      onTap: _selectExpiryDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Expiry Date',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
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
        child: Text(
          '${_selectedExpiryDate.day.toString().padLeft(2, '0')}/'
          '${_selectedExpiryDate.month.toString().padLeft(2, '0')}/'
          '${_selectedExpiryDate.year}',
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  Widget _buildAvailabilitySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Product Available',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _isAvailable
              ? 'Customers can see and request this product.'
              : 'This product is hidden from the marketplace.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        value: _isAvailable,
        onChanged: (value) {
          setState(() {
            _isAvailable = value;
          });
        },
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (!_canEditProduct) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(title: const Text('Edit Product'), centerTitle: true),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            // ======================================================
            // PRODUCT INFORMATION
            // ======================================================
            _buildSectionTitle(
              'Product Information',
              'Update the basic information of this product.',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'Enter product name',
              icon: Icons.medication_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            _buildTextField(
              controller: _manufacturerController,
              label: 'Manufacturer',
              hint: 'Enter manufacturer name',
              icon: Icons.business_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Manufacturer is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            _buildDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              icon: Icons.category_outlined,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 14),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe the product',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            _buildTextField(
              controller: _imageUrlController,
              label: 'Image URL',
              hint: 'https://example.com/image.jpg',
              icon: Icons.image_outlined,
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 28),

            // ======================================================
            // STOCK & PRICING
            // ======================================================
            _buildSectionTitle(
              'Stock & Pricing',
              'Update quantity, minimum order and price.',
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Available Quantity',
                    hint: '0',
                    icon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final number = int.tryParse(value?.trim() ?? '');

                      if (number == null) {
                        return 'Enter quantity';
                      }

                      if (number < 0) {
                        return 'Invalid quantity';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildTextField(
                    controller: _minimumOrderController,
                    label: 'Minimum Order',
                    hint: '1',
                    icon: Icons.shopping_cart_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final number = int.tryParse(value?.trim() ?? '');

                      if (number == null || number <= 0) {
                        return 'Invalid amount';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildTextField(
              controller: _priceController,
              label: 'Price (Rs.)',
              hint: '0.00',
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final number = double.tryParse(value?.trim() ?? '');

                if (number == null || number <= 0) {
                  return 'Enter valid price';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _buildDropdown(
              label: 'Unit',
              value: _selectedUnit,
              items: _units,
              icon: Icons.straighten_outlined,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedUnit = value;
                });
              },
            ),

            const SizedBox(height: 28),

            // ======================================================
            // STORAGE & EXPIRY
            // ======================================================
            _buildSectionTitle(
              'Storage & Expiry',
              'Update storage requirements and expiry information.',
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Storage Temperature',
              value: _selectedStorage,
              items: _storageOptions,
              icon: Icons.thermostat_outlined,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedStorage = value;
                });
              },
            ),

            const SizedBox(height: 14),

            _buildExpiryDate(),

            const SizedBox(height: 28),

            // ======================================================
            // MARKETPLACE VISIBILITY
            // ======================================================
            _buildSectionTitle(
              'Marketplace Visibility',
              'Control whether customers can request this product.',
            ),

            const SizedBox(height: 16),

            _buildAvailabilitySwitch(),

            const SizedBox(height: 30),

            // ======================================================
            // SAVE BUTTON
            // ======================================================
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProduct,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving Changes...' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
