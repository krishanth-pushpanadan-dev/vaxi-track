import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vaccineNameController = TextEditingController();

  final TextEditingController _batchNumberController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _manufacturerController = TextEditingController();

  final TextEditingController _supplierController = TextEditingController();

  final TextEditingController _storageLocationController =
      TextEditingController();

  DateTime? _expiryDate;

  String _unit = 'Doses';

  bool _isSaving = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _batchNumberController.dispose();
    _quantityController.dispose();
    _manufacturerController.dispose();
    _supplierController.dispose();
    _storageLocationController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE STOCK
  // ============================================================

  Future<void> _saveStock() async {
    final user = _authService.currentUser;

    if (user == null) {
      _showMessage("User is not logged in.");
      return;
    }

    // Permission check
    if (!RolePermissions.canAddInventory(user.role)) {
      _showMessage("You don't have permission to add inventory.");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expiryDate == null) {
      _showMessage("Please select the expiry date.");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ----------------------------------------------------------
      // TODO:
      // Firebase inventory creation will be added here.
      //
      // Example later:
      //
      // await InventoryService().addStock(
      //   vaccineName: _vaccineNameController.text.trim(),
      //   batchNumber: _batchNumberController.text.trim(),
      //   quantity: int.parse(_quantityController.text.trim()),
      //   unit: _unit,
      //   manufacturer: _manufacturerController.text.trim(),
      //   supplier: _supplierController.text.trim(),
      //   storageLocation:
      //       _storageLocationController.text.trim(),
      //   expiryDate: _expiryDate!,
      // );
      // ----------------------------------------------------------

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stock added successfully.")),
      );

      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // EXPIRY DATE
  // ============================================================

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return "$day/$month/$year";
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    // ------------------------------------------------------------
    // Permission protection
    // ------------------------------------------------------------

    if (user == null || !RolePermissions.canAddInventory(user.role)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Add Stock"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            "You don't have permission to add stock.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        title: const Text(
          "Add Stock",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ====================================================
              // HEADER
              // ====================================================
              const Text(
                "Add Vaccine Stock",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "Enter the vaccine stock and batch information.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 25),

              // ====================================================
              // VACCINE INFORMATION
              // ====================================================
              _sectionTitle(
                icon: Icons.vaccines_rounded,
                title: "Vaccine Information",
              ),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _vaccineNameController,
                label: "Vaccine Name",
                hint: "e.g. Pfizer COVID-19",
                icon: Icons.vaccines_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter vaccine name";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _batchNumberController,
                label: "Batch Number",
                hint: "e.g. VX-2026-001",
                icon: Icons.qr_code_2_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter batch number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _manufacturerController,
                label: "Manufacturer",
                hint: "e.g. Pfizer",
                icon: Icons.factory_outlined,
              ),

              const SizedBox(height: 25),

              // ====================================================
              // STOCK INFORMATION
              // ====================================================
              _sectionTitle(
                icon: Icons.inventory_2_rounded,
                title: "Stock Information",
              ),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _quantityController,
                label: "Quantity",
                hint: "Enter quantity",
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter quantity";
                  }

                  final quantity = int.tryParse(value.trim());

                  if (quantity == null || quantity <= 0) {
                    return "Enter a valid quantity";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // ----------------------------------------------------
              // UNIT
              // ----------------------------------------------------
              _buildDropdown(),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _supplierController,
                label: "Supplier",
                hint: "Enter supplier name",
                icon: Icons.local_shipping_outlined,
              ),

              const SizedBox(height: 25),

              // ====================================================
              // STORAGE INFORMATION
              // ====================================================
              _sectionTitle(
                icon: Icons.warehouse_rounded,
                title: "Storage Information",
              ),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _storageLocationController,
                label: "Storage Location",
                hint: "e.g. Cold Room A",
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 15),

              // ----------------------------------------------------
              // EXPIRY DATE
              // ----------------------------------------------------
              _buildDateField(),

              const SizedBox(height: 30),

              // ====================================================
              // SAVE BUTTON
              // ====================================================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveStock,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline),

                            SizedBox(width: 10),

                            Text(
                              "Add Stock",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, color: AppColors.primary, size: 20),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon, color: AppColors.primary),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: DropdownButtonFormField<String>(
        initialValue: _unit,

        decoration: InputDecoration(
          labelText: "Unit",

          prefixIcon: const Icon(
            Icons.straighten_rounded,
            color: AppColors.primary,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),

        items: const [
          DropdownMenuItem(value: "Doses", child: Text("Doses")),
          DropdownMenuItem(value: "Vials", child: Text("Vials")),
          DropdownMenuItem(value: "Boxes", child: Text("Boxes")),
        ],

        onChanged: (value) {
          if (value != null) {
            setState(() {
              _unit = value;
            });
          }
        },
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectExpiryDate,

      borderRadius: BorderRadius.circular(14),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Expiry Date",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _expiryDate == null
                        ? "Select expiry date"
                        : _formatDate(_expiryDate!),
                    style: TextStyle(
                      fontSize: 15,
                      color: _expiryDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
