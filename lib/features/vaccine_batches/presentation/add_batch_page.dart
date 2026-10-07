import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_colors.dart';
import '../services/ocr_service.dart';

class AddBatchPage extends StatefulWidget {
  const AddBatchPage({super.key});

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final TextEditingController vaccineController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // ============================================================
  // OCR
  // ============================================================

  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();

  File? scannedImage;
  bool isScanning = false;
  String extractedText = "";

  // ============================================================
  // DROPDOWN VALUES
  // ============================================================

  String status = "Stored";
  String temperature = "2°C - 8°C";
  String hospital = "Colombo General Hospital";

  // ============================================================
  // DATES
  // ============================================================

  DateTime? manufacturingDate;
  DateTime? expiryDate;

  // ============================================================
  // MANUFACTURING DATE
  // ============================================================

  Future<void> pickManufacturingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: manufacturingDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        manufacturingDate = picked;
      });
    }
  }

  // ============================================================
  // EXPIRY DATE
  // ============================================================

  Future<void> pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

  // ============================================================
  // OCR SCANNER
  // ============================================================

  Future<void> scanLabel() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        scannedImage = File(image.path);
        isScanning = true;
        extractedText = "";
      });

      final text = await _ocrService.extractText(image.path);

      if (!mounted) return;

      setState(() {
        extractedText = text;
      });

      parseBatchData(text);

      if (!mounted) return;

      setState(() {
        isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Label scanned successfully. Please verify the extracted data.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isScanning = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to scan label: $e")));
    }
  }

  // ============================================================
  // PARSE OCR DATA
  // ============================================================

  void parseBatchData(String text) {
    final normalizedText = text
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();

    _extractBatchNumber(normalizedText);
    _extractManufacturingDate(normalizedText);
    _extractExpiryDate(normalizedText);
    _extractVaccineName(normalizedText);
  }
  // ============================================================
  // EXTRACT BATCH / LOT NUMBER
  // ============================================================

  void _extractBatchNumber(String text) {
    final batchRegex = RegExp(
      r'(?:batch|batch\s*no\.?|batch\s*number|lot|lot\s*no\.?|lot\s*number)'
      r'\s*[:#\-]?\s*([A-Za-z0-9][A-Za-z0-9\-\/]*)',
      caseSensitive: false,
    );

    final match = batchRegex.firstMatch(text);

    if (match != null) {
      final batchNumber = match.group(1)?.trim();

      if (batchNumber != null && batchNumber.isNotEmpty) {
        batchController.text = batchNumber;
      }
    }
  }

  // ============================================================
  // EXTRACT MANUFACTURING DATE
  // ============================================================

  void _extractManufacturingDate(String text) {
    final manufacturingRegex = RegExp(
      r'(?:mfg|mfd|manufactured|manufacturing\s*date)'
      r'\s*[:\-]?\s*'
      r'(\d{1,2}[\/\-.]\d{1,2}[\/\-.]\d{2,4})',
      caseSensitive: false,
    );

    final match = manufacturingRegex.firstMatch(text);

    if (match != null) {
      final date = _parseDate(match.group(1));

      if (date != null) {
        setState(() {
          manufacturingDate = date;
        });
      }
    }
  }

  // ============================================================
  // EXTRACT EXPIRY DATE
  // ============================================================

  void _extractExpiryDate(String text) {
    final expiryRegex = RegExp(
      r'(?:exp|expiry|expires|expiration|expiry\s*date|expiration\s*date)'
      r'\s*[:\-]?\s*'
      r'(\d{1,2}[\/\-.]\d{1,2}[\/\-.]\d{2,4}|\d{1,2}[\/\-.]\d{2,4})',
      caseSensitive: false,
    );

    final match = expiryRegex.firstMatch(text);

    if (match != null) {
      final dateText = match.group(1);

      final date = _parseDate(dateText);

      if (date != null) {
        setState(() {
          expiryDate = date;
        });
      }
    }
  }

  // ============================================================
  // PARSE DATE
  // ============================================================

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final cleaned = value.trim().replaceAll('-', '/').replaceAll('.', '/');

    final parts = cleaned.split('/');

    try {
      // ----------------------------------------------------------
      // Full date: DD/MM/YYYY
      // ----------------------------------------------------------

      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        int year = int.parse(parts[2]);

        if (year < 100) {
          year += 2000;
        }

        final date = DateTime(year, month, day);

        if (date.year != year || date.month != month || date.day != day) {
          return null;
        }

        return date;
      }

      // ----------------------------------------------------------
      // Month / Year: MM/YYYY
      // ----------------------------------------------------------

      if (parts.length == 2) {
        final month = int.parse(parts[0]);

        int year = int.parse(parts[1]);

        if (year < 100) {
          year += 2000;
        }

        if (month < 1 || month > 12) {
          return null;
        }

        // For expiry dates such as 12/2027,
        // use the last day of that month.
        return DateTime(year, month + 1, 0);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // EXTRACT VACCINE NAME
  // ============================================================

  void _extractVaccineName(String text) {
    final knownProducts = [
      'Pfizer',
      'Moderna',
      'AstraZeneca',
      'Sinopharm',
      'Sinovac',
      'Covishield',
      'Comirnaty',
    ];

    for (final product in knownProducts) {
      if (text.toLowerCase().contains(product.toLowerCase())) {
        vaccineController.text = product;
        return;
      }
    }
  }

  // ============================================================
  // REGISTER BATCH
  // ============================================================

  void registerBatch() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Date validation
    if (manufacturingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the manufacturing date.")),
      );
      return;
    }

    if (expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select the expiry date.")),
      );
      return;
    }

    // Manufacturing date should not be after expiry date.
    if (manufacturingDate!.isAfter(expiryDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Manufacturing date cannot be after expiry date."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Vaccine Batch Registered Successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Required";
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // DATE TILE
  // ============================================================

  Widget buildDateTile(String title, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  date == null
                      ? title
                      : "${date.day}/${date.month}/${date.year}",
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OCR SCANNER SECTION
  // ============================================================

  Widget _buildScannerSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.document_scanner, color: AppColors.primary),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scan Vaccine Label",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Extract batch and expiry information automatically",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Image Preview
          if (scannedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                scannedImage!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),

          if (scannedImage != null) const SizedBox(height: 15),

          // Scan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isScanning ? null : scanLabel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(isScanning ? "Scanning Label..." : "Scan Label"),
            ),
          ),

          // OCR Result
          if (extractedText.isNotEmpty && !isScanning) ...[
            const SizedBox(height: 15),

            const Text(
              "OCR Result",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                extractedText,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    vaccineController.dispose();
    batchController.dispose();
    quantityController.dispose();
    notesController.dispose();

    _ocrService.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text("Add Vaccine Batch"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ==================================================
              // OCR SCANNER
              // ==================================================
              _buildScannerSection(),

              // ==================================================
              // VACCINE NAME
              // ==================================================
              buildTextField("Vaccine Name", vaccineController, Icons.vaccines),

              // ==================================================
              // BATCH NUMBER
              // ==================================================
              buildTextField("Batch Number", batchController, Icons.qr_code),

              // ==================================================
              // NUMBER OF DOSES
              // ==================================================
              buildTextField(
                "Number of Doses",
                quantityController,
                Icons.inventory,
              ),

              // ==================================================
              // MANUFACTURING DATE
              // ==================================================
              buildDateTile(
                "Manufacturing Date",
                manufacturingDate,
                pickManufacturingDate,
              ),

              // ==================================================
              // EXPIRY DATE
              // ==================================================
              buildDateTile("Expiry Date", expiryDate, pickExpiryDate),

              // ==================================================
              // STORAGE TEMPERATURE
              // ==================================================
              buildDropdown(
                "Storage Temperature",
                temperature,
                ["2°C - 8°C", "-20°C", "-70°C"],
                (v) {
                  if (v != null) {
                    setState(() {
                      temperature = v;
                    });
                  }
                },
              ),

              // ==================================================
              // STATUS
              // ==================================================
              buildDropdown(
                "Status",
                status,
                ["Stored", "Transit", "Delivered"],
                (v) {
                  if (v != null) {
                    setState(() {
                      status = v;
                    });
                  }
                },
              ),

              // ==================================================
              // ASSIGNED HOSPITAL
              // ==================================================
              buildDropdown(
                "Assigned Hospital",
                hospital,
                [
                  "Colombo General Hospital",
                  "Kandy Teaching Hospital",
                  "Jaffna Hospital",
                  "Galle Hospital",
                ],
                (v) {
                  if (v != null) {
                    setState(() {
                      hospital = v;
                    });
                  }
                },
              ),

              // ==================================================
              // NOTES
              // ==================================================
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Additional Notes",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              // ==================================================
              // REGISTER BUTTON
              // ==================================================
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: registerBatch,
                  icon: const Icon(Icons.check),
                  label: const Text(
                    "Register Batch",
                    style: TextStyle(fontSize: 18),
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
