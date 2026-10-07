import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/waste_item_model.dart';

class WasteDetailsPage extends StatefulWidget {
  final WasteItem wasteItem;

  const WasteDetailsPage({super.key, required this.wasteItem});

  @override
  State<WasteDetailsPage> createState() => _WasteDetailsPageState();
}

class _WasteDetailsPageState extends State<WasteDetailsPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // LOCAL WASTE ITEM
  // ============================================================

  late WasteItem _wasteItem;

  // ============================================================
  // ROLE CHECK
  // ============================================================

  bool get canApproveWaste {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canApproveWaste(user.role);
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _wasteItem = widget.wasteItem;
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;

    switch (_wasteItem.status) {
      case WasteStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;

      case WasteStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;

      case WasteStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _wasteItem.statusLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // REASON ICON
  // ============================================================

  IconData _reasonIcon() {
    switch (_wasteItem.reason) {
      case WasteReason.expired:
        return Icons.event_busy;

      case WasteReason.damaged:
        return Icons.broken_image_outlined;

      case WasteReason.temperatureExcursion:
        return Icons.thermostat;

      case WasteReason.contaminated:
        return Icons.warning_amber_rounded;

      case WasteReason.other:
        return Icons.more_horiz;
    }
  }

  // ============================================================
  // DATE FORMATTER
  // ============================================================

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow(String title, String value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 19, color: AppColors.primary),
            const SizedBox(width: 10),
          ],

          SizedBox(
            width: 105,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 21, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE SECTION
  // ============================================================

  Widget _buildImageSection() {
    if (_wasteItem.imagePath.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              "No image available",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(_wasteItem.imagePath),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 180,
            color: Colors.grey.shade100,
            child: const Center(child: Text("Unable to display image")),
          );
        },
      ),
    );
  }

  // ============================================================
  // APPROVE WASTE
  // ============================================================

  Future<void> _approveWaste() async {
    // Security check
    if (!canApproveWaste) {
      _showMessage("Only Admin can approve waste cases.", Colors.red);
      return;
    }

    // Confirmation
    final confirmed = await _showConfirmationDialog(
      title: "Approve Waste Case?",
      message: "Are you sure you want to approve ${_wasteItem.id}?",
      confirmText: "Approve",
      confirmColor: Colors.green,
    );

    if (!confirmed || !mounted) {
      return;
    }

    // Create updated item
    final updatedItem = _wasteItem.copyWith(
      status: WasteStatus.approved,
      requiresReview: false,
    );

    // Return updated item to Waste Management page
    Navigator.pop(context, updatedItem);
  }

  // ============================================================
  // REJECT WASTE
  // ============================================================

  Future<void> _rejectWaste() async {
    // Security check
    if (!canApproveWaste) {
      _showMessage("Only Admin can reject waste cases.", Colors.red);
      return;
    }

    // Confirmation
    final confirmed = await _showConfirmationDialog(
      title: "Reject Waste Case?",
      message: "Are you sure you want to reject ${_wasteItem.id}?",
      confirmText: "Reject",
      confirmColor: Colors.red,
    );

    if (!confirmed || !mounted) {
      return;
    }

    // Create updated item
    final updatedItem = _wasteItem.copyWith(
      status: WasteStatus.rejected,
      requiresReview: false,
    );

    // Return updated item to Waste Management page
    Navigator.pop(context, updatedItem);
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
        title: Text("Waste Case ${_wasteItem.id}"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _reasonIcon(),
                      color: AppColors.primary,
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _wasteItem.medicineName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _wasteItem.reasonLabel,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildStatusChip(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // MEDICINE INFORMATION
            // ==================================================
            _buildSectionTitle(
              "Medicine Information",
              Icons.medication_outlined,
            ),

            _buildDetailRow(
              "Medicine",
              _wasteItem.medicineName,
              icon: Icons.medication_outlined,
            ),

            _buildDetailRow(
              "Batch Number",
              _wasteItem.batchNumber,
              icon: Icons.qr_code_2,
            ),

            _buildDetailRow(
              "Quantity",
              "${_wasteItem.quantity} ${_wasteItem.unit}",
              icon: Icons.inventory_2_outlined,
            ),

            _buildDetailRow(
              "Waste Reason",
              _wasteItem.reasonLabel,
              icon: _reasonIcon(),
            ),

            if (_wasteItem.expiryDate != null)
              _buildDetailRow(
                "Expiry Date",
                _formatDate(_wasteItem.expiryDate!),
                icon: Icons.event_outlined,
              ),

            const SizedBox(height: 12),

            // ==================================================
            // EXPIRY WARNING
            // ==================================================
            if (_wasteItem.isExpired)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "This medicine has passed its expiry date.",
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // LOCATION & REPORTER
            // ==================================================
            _buildSectionTitle("Report Information", Icons.assignment_outlined),

            _buildDetailRow(
              "Location",
              _wasteItem.location,
              icon: Icons.location_on_outlined,
            ),

            _buildDetailRow(
              "Reported By",
              _wasteItem.reportedBy,
              icon: Icons.person_outline,
            ),

            _buildDetailRow(
              "Role",
              _wasteItem.reportedByRole,
              icon: Icons.badge_outlined,
            ),

            _buildDetailRow(
              "Reported Date",
              _formatDate(_wasteItem.reportedDate),
              icon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 12),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            _buildSectionTitle("Description", Icons.description_outlined),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _wasteItem.description.isEmpty
                    ? "No description provided."
                    : _wasteItem.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // IMAGE
            // ==================================================
            _buildSectionTitle("Evidence Image", Icons.photo_camera_outlined),

            _buildImageSection(),

            const SizedBox(height: 24),

            // ==================================================
            // REVIEW STATUS
            // ==================================================
            if (_wasteItem.requiresReview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.pending_actions, color: Colors.orange.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Admin Review Required",
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "This waste case is waiting for "
                            "Admin approval.",
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // ADMIN ACTIONS
            // ==================================================
            if (_wasteItem.status == WasteStatus.pending &&
                canApproveWaste) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                "Admin Actions",
                Icons.admin_panel_settings_outlined,
              ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _approveWaste,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text(
                    "Approve Waste Case",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _rejectWaste,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text(
                    "Reject Waste Case",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            // ==================================================
            // NON-ADMIN MESSAGE
            // ==================================================
            if (_wasteItem.status == WasteStatus.pending &&
                !canApproveWaste) ...[
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "This waste case is waiting for "
                        "Admin review.",
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
