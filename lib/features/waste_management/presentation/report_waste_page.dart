import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_colors.dart';
import '../../alerts/services/alert_service.dart';
import '../../authentication/services/auth_service.dart';
import '../../authentication/models/user_model.dart';
import '../model/waste_item_model.dart';
import '../services/waste_ocr_service.dart';

class ReportWastePage extends StatefulWidget {
  const ReportWastePage({super.key});

  @override
  State<ReportWastePage> createState() => _ReportWastePageState();
}

class _ReportWastePageState extends State<ReportWastePage> {
  final _formKey = GlobalKey<FormState>();

  // ==============================================================
  // SERVICES
  // ==============================================================

  final AuthService _authService = AuthService();

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  final TextEditingController medicineController = TextEditingController();

  final TextEditingController batchController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  // ==============================================================
  // IMAGE / OCR
  // ==============================================================

  final ImagePicker _picker = ImagePicker();
  final WasteOcrService _ocrService = WasteOcrService();

  File? capturedImage;

  bool isAnalyzingImage = false;

  String extractedText = '';

  String? imageAnalysisMessage;

  // ==============================================================
  // ANALYSIS RESULTS
  // ==============================================================

  bool possibleDamageDetected = false;
  bool expiryInformationDetected = false;

  bool issueVerified = false;

  WasteReason? suggestedReason;

  // ==============================================================
  // FORM VALUES
  // ==============================================================

  WasteReason selectedReason = WasteReason.expired;

  String selectedUnit = 'Units';

  String selectedLocation = 'Central Warehouse';

  DateTime? expiryDate;

  // ==============================================================
  // MOCK DATA
  // ==============================================================

  final List<String> units = [
    'Units',
    'Vials',
    'Boxes',
    'Bottles',
    'Packets',
    'Doses',
  ];

  final List<String> locations = [
    'Central Warehouse',
    'Regional Warehouse',
    'Colombo General Hospital',
    'Kandy General Hospital',
    'Jaffna Teaching Hospital',
  ];

  // ==============================================================
  // CAPTURE + ANALYZE IMAGE
  // ==============================================================

  Future<void> captureAndAnalyzeImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        capturedImage = File(image.path);

        isAnalyzingImage = true;

        imageAnalysisMessage = null;

        extractedText = '';

        possibleDamageDetected = false;

        expiryInformationDetected = false;

        issueVerified = false;

        suggestedReason = null;
      });

      // ------------------------------------------------------------
      // STEP 1 — OCR
      // ------------------------------------------------------------

      final text = await _ocrService.extractText(image.path);

      if (!mounted) {
        return;
      }

      setState(() {
        extractedText = text;
      });

      // ------------------------------------------------------------
      // STEP 2 — PARSE OCR INFORMATION
      // ------------------------------------------------------------

      parseWasteLabel(text);

      // ------------------------------------------------------------
      // STEP 3 — IMAGE ANALYSIS
      // ------------------------------------------------------------

      final analysis = await _ocrService.analyzeImage(
        imagePath: image.path,
        extractedText: text,
      );

      if (!mounted) {
        return;
      }

      // ------------------------------------------------------------
      // DETERMINE SUGGESTED REASON
      // ------------------------------------------------------------

      WasteReason? detectedReason;

      if (analysis.possibleDamage) {
        detectedReason = WasteReason.damaged;
      } else if (expiryDate != null && expiryDate!.isBefore(DateTime.now())) {
        detectedReason = WasteReason.expired;
      } else if (analysis.hasExpiryInformation) {
        detectedReason = null;
      } else {
        detectedReason = WasteReason.other;
      }

      setState(() {
        possibleDamageDetected = analysis.possibleDamage;

        expiryInformationDetected = analysis.hasExpiryInformation;

        imageAnalysisMessage = analysis.message;

        suggestedReason = detectedReason;

        isAnalyzingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image analyzed. Please review the suggested waste reason.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isAnalyzingImage = false;

        imageAnalysisMessage =
            'Unable to analyze the image. Please enter the information manually.';

        suggestedReason = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image analysis failed: $e')));
    }
  }

  // ==============================================================
  // PARSE OCR LABEL
  // ==============================================================

  void parseWasteLabel(String text) {
    final normalizedText = text.toLowerCase();

    // ------------------------------------------------------------
    // MEDICINE NAME
    // ------------------------------------------------------------

    final medicineName = extractMedicineName(normalizedText);

    if (medicineName != null) {
      medicineController.text = medicineName;
    }

    // ------------------------------------------------------------
    // BATCH NUMBER
    // ------------------------------------------------------------

    final batchNumber = extractBatchNumber(text);

    if (batchNumber != null) {
      batchController.text = batchNumber;
    }

    // ------------------------------------------------------------
    // EXPIRY DATE
    // ------------------------------------------------------------

    final detectedExpiryDate = extractExpiryDate(text);

    if (detectedExpiryDate != null) {
      setState(() {
        expiryDate = detectedExpiryDate;
      });
    }

    // ------------------------------------------------------------
    // EXPIRY KEYWORD
    // ------------------------------------------------------------

    final hasExpiry =
        normalizedText.contains('exp') ||
        normalizedText.contains('expiry') ||
        normalizedText.contains('expiration') ||
        normalizedText.contains('expires');

    setState(() {
      expiryInformationDetected = hasExpiry;
    });
  }

  // ==============================================================
  // MEDICINE NAME EXTRACTION
  // ==============================================================

  String? extractMedicineName(String text) {
    final knownMedicines = [
      'Pfizer',
      'Moderna',
      'AstraZeneca',
      'Sinopharm',
      'Sinovac',
      'Covishield',
      'Comirnaty',
      'Paracetamol',
      'Amoxicillin',
      'Insulin',
    ];

    for (final medicine in knownMedicines) {
      if (text.contains(medicine.toLowerCase())) {
        return medicine;
      }
    }

    return null;
  }

  // ==============================================================
  // BATCH NUMBER EXTRACTION
  // ==============================================================

  String? extractBatchNumber(String text) {
    final patterns = [
      RegExp(
        r'(?:batch|batch\s*no|batch\s*number)\s*[:#\-]?\s*([A-Z0-9\/\-_]+)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:lot|lot\s*no|lot\s*number)\s*[:#\-]?\s*([A-Z0-9\/\-_]+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null && match.groupCount >= 1) {
        final value = match.group(1)?.trim();

        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  // ==============================================================
  // EXPIRY DATE EXTRACTION
  // ==============================================================

  DateTime? extractExpiryDate(String text) {
    final patterns = [
      RegExp(
        r'(?:exp|expiry|expires|expiration|expiry\s*date|expiration\s*date)'
        r'\s*[:\-]?\s*(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:exp|expiry|expires|expiration|expiry\s*date|expiration\s*date)'
        r'\s*[:\-]?\s*(\d{1,2}[\/\-]\d{4})',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null && match.groupCount >= 1) {
        final value = match.group(1);

        if (value != null) {
          final parsed = parseExpiryDate(value);

          if (parsed != null) {
            return parsed;
          }
        }
      }
    }

    return null;
  }

  // ==============================================================
  // PARSE DATE
  // ==============================================================

  DateTime? parseExpiryDate(String value) {
    final cleaned = value.trim().replaceAll('-', '/');

    // ------------------------------------------------------------
    // DD/MM/YYYY
    // ------------------------------------------------------------

    final fullDateMatch = RegExp(
      r'^(\d{1,2})\/(\d{1,2})\/(\d{2,4})$',
    ).firstMatch(cleaned);

    if (fullDateMatch != null) {
      final day = int.tryParse(fullDateMatch.group(1)!);

      final month = int.tryParse(fullDateMatch.group(2)!);

      var year = int.tryParse(fullDateMatch.group(3)!);

      if (day == null || month == null || year == null) {
        return null;
      }

      if (year < 100) {
        year += 2000;
      }

      try {
        return DateTime(year, month, day);
      } catch (_) {
        return null;
      }
    }

    // ------------------------------------------------------------
    // MM/YYYY
    // ------------------------------------------------------------

    final monthYearMatch = RegExp(r'^(\d{1,2})\/(\d{4})$').firstMatch(cleaned);

    if (monthYearMatch != null) {
      final month = int.tryParse(monthYearMatch.group(1)!);

      final year = int.tryParse(monthYearMatch.group(2)!);

      if (month == null || year == null) {
        return null;
      }

      try {
        return DateTime(year, month + 1, 0);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // ==============================================================
  // APPLY SUGGESTED REASON
  // ==============================================================

  void applySuggestedReason() {
    if (suggestedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No specific waste reason could be suggested.'),
        ),
      );

      return;
    }

    setState(() {
      selectedReason = suggestedReason!;
      issueVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Suggested reason applied: ${reasonLabel(suggestedReason!)}',
        ),
      ),
    );
  }

  // ==============================================================
  // VERIFY DETECTED ISSUE
  // ==============================================================

  void verifyDetectedIssue() {
    if (suggestedReason == null) {
      setState(() {
        issueVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Information verified. Please select the appropriate waste reason.',
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedReason = suggestedReason!;
      issueVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Detected issue verified. Reason: ${reasonLabel(suggestedReason!)}',
        ),
      ),
    );
  }

  // ==============================================================
  // MANUAL EXPIRY DATE
  // ==============================================================

  Future<void> pickExpiryDate() async {
    final now = DateTime.now();

    final DateTime initialDate = expiryDate ?? now;

    final DateTime firstDate = DateTime(2000, 1, 1);

    final DateTime lastDate = DateTime(now.year + 20, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
          ? lastDate
          : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select expiry date',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      expiryDate = picked;

      if (picked.isBefore(DateTime.now())) {
        suggestedReason = WasteReason.expired;

        selectedReason = WasteReason.expired;
      }

      issueVerified = false;
    });
  }

  // ==============================================================
  // SUBMIT WASTE
  // ==============================================================

  Future<void> submitWaste() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the expiry date.')),
      );

      return;
    }

    final quantity = int.tryParse(quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity.')),
      );

      return;
    }

    // ------------------------------------------------------------
    // EXPIRED VALIDATION
    // ------------------------------------------------------------

    if (selectedReason == WasteReason.expired &&
        !expiryDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected medicine is not expired yet. Please verify the expiry date or choose another reason.',
          ),
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // CURRENT USER
    // ------------------------------------------------------------

    final user = _authService.currentUser;

    final String reportedBy = user?.name ?? 'Current User';

    final String reportedByRole = user?.role.name ?? 'Unknown';

    // ------------------------------------------------------------
    // CREATE MOCK WASTE ITEM
    // ------------------------------------------------------------

    final wasteItem = WasteItem(
      id: 'WST-${DateTime.now().millisecondsSinceEpoch}',
      medicineName: medicineController.text.trim(),
      batchNumber: batchController.text.trim(),
      quantity: quantity,
      unit: selectedUnit,
      reason: selectedReason,
      status: WasteStatus.pending,
      reportedBy: reportedBy,
      reportedByRole: reportedByRole,
      description: descriptionController.text.trim(),
      imagePath: capturedImage?.path ?? '',
      reportedDate: DateTime.now(),
      expiryDate: expiryDate,
      location: selectedLocation,
      requiresReview: true,
    );

    // ------------------------------------------------------------
    // CREATE ALERT
    // ------------------------------------------------------------

    AlertService.createWasteAlert(wasteItem);

    // ------------------------------------------------------------
    // SUCCESS DIALOG
    // ------------------------------------------------------------

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Expanded(child: Text('Waste Report Submitted')),
            ],
          ),
          content: const Text(
            'The waste report has been submitted successfully and is waiting for Admin review.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, wasteItem);
  }

  // ==============================================================
  // TEXT FIELD
  // ==============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  // ==============================================================
  // DROPDOWN
  // ==============================================================

  Widget buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ==============================================================
  // EXPIRY DATE TILE
  // ==============================================================

  Widget buildExpiryDateTile() {
    final hasDate = expiryDate != null;

    final isExpired = hasDate && expiryDate!.isBefore(DateTime.now());

    return InkWell(
      onTap: pickExpiryDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isExpired
                ? Colors.red.withValues(alpha: 0.5)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isExpired ? Colors.red.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: isExpired ? Colors.red : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiry Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasDate ? formatDate(expiryDate!) : 'Select expiry date',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: hasDate ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  if (isExpired) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Medicine appears to be expired',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // FORMAT DATE
  // ==============================================================

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ==============================================================
  // IMAGE ANALYSIS SECTION
  // ==============================================================

  Widget buildImageAnalysisSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Medicine Image Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Capture the medicine label to extract information and identify possible issues.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          if (capturedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                capturedImage!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 42, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No medicine image captured',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAnalyzingImage ? null : captureAndAnalyzeImage,
              icon: isAnalyzingImage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(
                isAnalyzingImage ? 'Analyzing Image...' : 'Capture & Analyze',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (!isAnalyzingImage && imageAnalysisMessage != null) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: possibleDamageDetected
                    ? Colors.orange.withValues(alpha: 0.10)
                    : Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: possibleDamageDetected
                      ? Colors.orange.withValues(alpha: 0.30)
                      : Colors.blue.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    possibleDamageDetected
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    color: possibleDamageDetected ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      imageAnalysisMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (expiryInformationDetected)
              _buildDetectionRow(
                icon: Icons.event_outlined,
                title: 'Expiry information detected',
                subtitle: expiryDate != null
                    ? 'Expiry: ${formatDate(expiryDate!)}'
                    : 'Please verify expiry date',
                isWarning:
                    expiryDate != null && expiryDate!.isBefore(DateTime.now()),
              ),

            if (possibleDamageDetected) ...[
              const SizedBox(height: 8),
              _buildDetectionRow(
                icon: Icons.warning_amber_rounded,
                title: 'Possible damage detected',
                subtitle:
                    'Please visually inspect and verify the package condition.',
                isWarning: true,
              ),
            ],

            if (suggestedReason != null) ...[
              const SizedBox(height: 14),
              _buildSuggestedReasonCard(),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: issueVerified ? null : verifyDetectedIssue,
                icon: Icon(
                  issueVerified ? Icons.verified : Icons.fact_check_outlined,
                ),
                label: Text(
                  issueVerified
                      ? 'Issue Verified'
                      : 'Verify & Apply Suggestion',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          if (extractedText.trim().isNotEmpty) ...[
            const SizedBox(height: 14),

            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                'View Extracted OCR Text',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    extractedText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==============================================================
  // SUGGESTED REASON CARD
  // ==============================================================

  Widget _buildSuggestedReasonCard() {
    final reason = suggestedReason!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Suggested Waste Reason',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(_reasonIcon(reason), color: _reasonColor(reason)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reasonLabel(reason),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Please verify before applying.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: issueVerified ? null : applySuggestedReason,
              icon: Icon(issueVerified ? Icons.verified : Icons.check),
              label: Text(
                issueVerified ? 'Suggestion Applied' : 'Apply Suggested Reason',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // DETECTION ROW
  // ==============================================================

  Widget _buildDetectionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isWarning,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.orange.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isWarning ? Colors.orange : Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // REASON ICON
  // ==============================================================

  IconData _reasonIcon(WasteReason reason) {
    switch (reason) {
      case WasteReason.expired:
        return Icons.event_busy_outlined;

      case WasteReason.damaged:
        return Icons.broken_image_outlined;

      case WasteReason.temperatureExcursion:
        return Icons.thermostat_outlined;

      case WasteReason.contaminated:
        return Icons.warning_outlined;

      case WasteReason.other:
        return Icons.help_outline;
    }
  }

  // ==============================================================
  // REASON COLOR
  // ==============================================================

  Color _reasonColor(WasteReason reason) {
    switch (reason) {
      case WasteReason.expired:
        return Colors.red;

      case WasteReason.damaged:
        return Colors.orange;

      case WasteReason.temperatureExcursion:
        return Colors.amber.shade800;

      case WasteReason.contaminated:
        return Colors.deepPurple;

      case WasteReason.other:
        return Colors.grey;
    }
  }

  // ==============================================================
  // WASTE REASON LABEL
  // ==============================================================

  String reasonLabel(WasteReason reason) {
    switch (reason) {
      case WasteReason.expired:
        return 'Expired';

      case WasteReason.damaged:
        return 'Damaged';

      case WasteReason.temperatureExcursion:
        return 'Temperature Excursion';

      case WasteReason.contaminated:
        return 'Contaminated';

      case WasteReason.other:
        return 'Other';
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Waste'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================
                const Text(
                  'Report Medicine Waste',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                Text(
                  'Record expired, damaged, contaminated, or otherwise unusable medicine.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // IMAGE ANALYSIS
                // ==================================================
                buildImageAnalysisSection(),

                const SizedBox(height: 24),

                // ==================================================
                // MEDICINE INFORMATION
                // ==================================================
                const Text(
                  'Medicine Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 14),

                buildTextField(
                  controller: medicineController,
                  label: 'Medicine Name',
                  hint: 'Enter medicine name',
                  icon: Icons.medication_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medicine name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                buildTextField(
                  controller: batchController,
                  label: 'Batch Number',
                  hint: 'Enter batch number',
                  icon: Icons.qr_code_2_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter batch number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                buildTextField(
                  controller: quantityController,
                  label: 'Quantity',
                  hint: 'Enter quantity',
                  icon: Icons.inventory_2_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter quantity';
                    }

                    final quantity = int.tryParse(value.trim());

                    if (quantity == null || quantity <= 0) {
                      return 'Enter a valid quantity';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                buildDropdown<String>(
                  label: 'Unit',
                  icon: Icons.straighten_outlined,
                  value: selectedUnit,
                  items: units,
                  itemLabel: (value) => value,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedUnit = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // WASTE DETAILS
                // ==================================================
                const Text(
                  'Waste Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 14),

                buildDropdown<WasteReason>(
                  label: 'Waste Reason',
                  icon: Icons.warning_amber_outlined,
                  value: selectedReason,
                  items: WasteReason.values,
                  itemLabel: (reason) => reasonLabel(reason),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedReason = value;

                      issueVerified = false;
                    });
                  },
                ),

                const SizedBox(height: 14),

                buildExpiryDateTile(),

                const SizedBox(height: 14),

                buildDropdown<String>(
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                  value: selectedLocation,
                  items: locations,
                  itemLabel: (value) => value,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                buildTextField(
                  controller: descriptionController,
                  label: 'Description',
                  hint: 'Describe the waste or problem...',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),

                const SizedBox(height: 24),

                // ==================================================
                // VERIFICATION NOTICE
                // ==================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Image analysis provides suggestions only. Please verify the medicine condition and information before submitting the waste report.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SUBMIT
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAnalyzingImage ? null : submitWaste,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Submit Waste Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    medicineController.dispose();
    batchController.dispose();
    quantityController.dispose();
    descriptionController.dispose();

    _ocrService.dispose();

    super.dispose();
  }
}
