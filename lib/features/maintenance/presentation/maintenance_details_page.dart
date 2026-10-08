import 'package:flutter/material.dart';
import 'package:vaxi_track/features/authentication/models/role_permissions.dart';

import '../../../app/app_colors.dart';
import '../../authentication/services/auth_service.dart';
import '../model/maintenance_item_model.dart';

class MaintenanceDetailsPage extends StatefulWidget {
  final MaintenanceItem maintenanceItem;

  const MaintenanceDetailsPage({super.key, required this.maintenanceItem});

  @override
  State<MaintenanceDetailsPage> createState() => _MaintenanceDetailsPageState();
}

class _MaintenanceDetailsPageState extends State<MaintenanceDetailsPage> {
  final AuthService _authService = AuthService();

  late MaintenanceItem _maintenanceItem;

  final List<String> _technicians = [
    'Nuwan Silva',
    'Kasun Perera',
    'Ravindu Fernando',
    'Chamod Jayasinghe',
  ];

  @override
  void initState() {
    super.initState();
    _maintenanceItem = widget.maintenanceItem;
  }

  bool get _canManageMaintenance {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canManageMaintenance(user.role);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pop(context, _maintenanceItem);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),

              _buildApprovalSection(),
              const SizedBox(height: 16),

              _buildStatusPrioritySection(),
              const SizedBox(height: 16),

              _buildDeviceSection(),
              const SizedBox(height: 16),

              _buildMaintenanceInformationSection(),
              const SizedBox(height: 16),

              _buildDescriptionSection(),
              const SizedBox(height: 16),

              _buildAssignmentSection(),
              const SizedBox(height: 16),

              _buildAdditionalInformationSection(),
              const SizedBox(height: 16),

              _buildTechnicianNotesSection(),
              const SizedBox(height: 16),

              if (_maintenanceItem.isOverdue) _buildOverdueWarning(),

              if (_canManageMaintenance) ...[
                const SizedBox(height: 16),
                _buildManagementActions(),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.build_circle_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _maintenanceItem.id,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _maintenanceItem.issueTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _maintenanceItem.deviceName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _maintenanceItem.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPROVAL SECTION
  // ============================================================

  Widget _buildApprovalSection() {
    Color statusColor;

    switch (_maintenanceItem.approvalStatus) {
      case MaintenanceApprovalStatus.pending:
        statusColor = Colors.orange;
        break;
      case MaintenanceApprovalStatus.approved:
        statusColor = Colors.green;
        break;
      case MaintenanceApprovalStatus.rejected:
        statusColor = Colors.red;
        break;
    }

    return _buildSectionCard(
      title: 'Approval Status',
      icon: Icons.verified_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(_getApprovalIcon(), color: statusColor, size: 25),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _maintenanceItem.approvalStatusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _getApprovalDescription(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_canManageMaintenance && _maintenanceItem.needsApproval) ...[
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rejectMaintenance,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _approveMaintenance,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getApprovalIcon() {
    switch (_maintenanceItem.approvalStatus) {
      case MaintenanceApprovalStatus.pending:
        return Icons.pending_actions_rounded;
      case MaintenanceApprovalStatus.approved:
        return Icons.check_circle_rounded;
      case MaintenanceApprovalStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  String _getApprovalDescription() {
    switch (_maintenanceItem.approvalStatus) {
      case MaintenanceApprovalStatus.pending:
        return 'This maintenance request is waiting for approval.';
      case MaintenanceApprovalStatus.approved:
        return 'This maintenance request has been approved.';
      case MaintenanceApprovalStatus.rejected:
        return 'This maintenance request has been rejected.';
    }
  }

  // ============================================================
  // STATUS + PRIORITY
  // ============================================================

  Widget _buildStatusPrioritySection() {
    return _buildSectionCard(
      title: 'Status & Priority',
      icon: Icons.flag_outlined,
      child: Row(
        children: [
          Expanded(
            child: _buildInfoChip(
              label: _maintenanceItem.statusLabel,
              color: _getStatusColor(_maintenanceItem.status),
              icon: Icons.sync_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildInfoChip(
              label: _maintenanceItem.priorityLabel,
              color: _getPriorityColor(_maintenanceItem.priority),
              icon: Icons.priority_high_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEVICE
  // ============================================================

  Widget _buildDeviceSection() {
    return _buildSectionCard(
      title: 'Device Information',
      icon: Icons.memory_rounded,
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.devices_other_rounded,
            label: 'Device',
            value: _maintenanceItem.deviceName,
          ),
          _buildDetailRow(
            icon: Icons.tag_rounded,
            label: 'Device ID',
            value: _maintenanceItem.deviceId,
          ),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: _maintenanceItem.location,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAINTENANCE INFORMATION
  // ============================================================

  Widget _buildMaintenanceInformationSection() {
    return _buildSectionCard(
      title: 'Maintenance Information',
      icon: Icons.build_outlined,
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.category_outlined,
            label: 'Type',
            value: _maintenanceItem.typeLabel,
          ),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Reported Date',
            value: _formatDate(_maintenanceItem.reportedDate),
          ),
          if (_maintenanceItem.scheduledDate != null)
            _buildDetailRow(
              icon: Icons.event_outlined,
              label: 'Scheduled Date',
              value: _formatDate(_maintenanceItem.scheduledDate!),
            ),
          if (_maintenanceItem.completedDate != null)
            _buildDetailRow(
              icon: Icons.task_alt_rounded,
              label: 'Completed Date',
              value: _formatDate(_maintenanceItem.completedDate!),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescriptionSection() {
    return _buildSectionCard(
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        _maintenanceItem.description,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT
  // ============================================================

  Widget _buildAssignmentSection() {
    return _buildSectionCard(
      title: 'Technician Assignment',
      icon: Icons.engineering_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _maintenanceItem.assignedTo ?? 'Not Assigned',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _maintenanceItem.assignedTo == null
                          ? 'A technician has not been assigned.'
                          : 'Assigned technician',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_canManageMaintenance) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showTechnicianSelection,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  _maintenanceItem.assignedTo == null
                      ? 'Assign Technician'
                      : 'Change Technician',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ADDITIONAL INFORMATION
  // ============================================================

  Widget _buildAdditionalInformationSection() {
    return _buildSectionCard(
      title: 'Additional Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Reported By',
            value: _maintenanceItem.reportedBy,
          ),
          _buildDetailRow(
            icon: Icons.badge_outlined,
            label: 'Reporter Role',
            value: _maintenanceItem.reportedByRole,
          ),
          _buildDetailRow(
            icon: Icons.attach_money_rounded,
            label: 'Maintenance Cost',
            value: _maintenanceItem.maintenanceCost == null
                ? 'Not available'
                : 'Rs. ${_maintenanceItem.maintenanceCost!.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TECHNICIAN NOTES
  // ============================================================

  Widget _buildTechnicianNotesSection() {
    return _buildSectionCard(
      title: 'Technician Notes',
      icon: Icons.notes_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _maintenanceItem.technicianNotes?.isNotEmpty == true
                ? _maintenanceItem.technicianNotes!
                : 'No technician notes available.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (_canManageMaintenance) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _editTechnicianNotes,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Edit Notes'),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // OVERDUE WARNING
  // ============================================================

  Widget _buildOverdueWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maintenance Overdue',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The scheduled maintenance date has passed and this task has not been completed.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MANAGEMENT ACTIONS
  // ============================================================

  Widget _buildManagementActions() {
    return _buildSectionCard(
      title: 'Management Actions',
      icon: Icons.admin_panel_settings_outlined,
      child: Column(
        children: [
          if (_maintenanceItem.approvalStatus ==
              MaintenanceApprovalStatus.approved) ...[
            if (_maintenanceItem.status == MaintenanceStatus.pending)
              _actionButton(
                label: 'Start Maintenance',
                icon: Icons.play_arrow_rounded,
                color: AppColors.primary,
                onPressed: _startMaintenance,
              ),

            if (_maintenanceItem.status == MaintenanceStatus.inProgress)
              _actionButton(
                label: 'Mark as Completed',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
                onPressed: _completeMaintenance,
              ),
          ],

          if (_maintenanceItem.status != MaintenanceStatus.completed &&
              _maintenanceItem.status != MaintenanceStatus.cancelled &&
              _maintenanceItem.approvalStatus !=
                  MaintenanceApprovalStatus.rejected)
            _actionButton(
              label: 'Cancel Maintenance',
              icon: Icons.cancel_outlined,
              color: Colors.red,
              onPressed: _cancelMaintenance,
            ),

          if (_maintenanceItem.approvalStatus ==
                  MaintenanceApprovalStatus.rejected &&
              _maintenanceItem.status != MaintenanceStatus.cancelled)
            _actionButton(
              label: 'Cancel Rejected Request',
              icon: Icons.cancel_outlined,
              color: Colors.red,
              onPressed: _cancelMaintenance,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> _approveMaintenance() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Approve Maintenance?',
      message: 'Are you sure you want to approve this maintenance request?',
      confirmText: 'Approve',
      confirmColor: Colors.green,
    );

    if (!confirmed) return;

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        approvalStatus: MaintenanceApprovalStatus.approved,
        requiresReview: false,
      );
    });

    _showMessage('Maintenance request approved successfully.', Colors.green);
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectMaintenance() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Reject Maintenance?',
      message: 'Are you sure you want to reject this maintenance request?',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );

    if (!confirmed) return;

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        approvalStatus: MaintenanceApprovalStatus.rejected,
        requiresReview: false,
      );
    });

    _showMessage('Maintenance request rejected.', Colors.red);
  }

  // ============================================================
  // START
  // ============================================================

  void _startMaintenance() {
    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        status: MaintenanceStatus.inProgress,
      );
    });

    _showMessage('Maintenance started.', AppColors.primary);
  }

  // ============================================================
  // COMPLETE
  // ============================================================

  Future<void> _completeMaintenance() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Complete Maintenance?',
      message: 'Mark this maintenance task as completed?',
      confirmText: 'Complete',
      confirmColor: Colors.green,
    );

    if (!confirmed) return;

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        status: MaintenanceStatus.completed,
        completedDate: DateTime.now(),
      );
    });

    _showMessage('Maintenance marked as completed.', Colors.green);
  }

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> _cancelMaintenance() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Cancel Maintenance?',
      message: 'Are you sure you want to cancel this maintenance task?',
      confirmText: 'Cancel Maintenance',
      confirmColor: Colors.red,
    );

    if (!confirmed) return;

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        status: MaintenanceStatus.cancelled,
      );
    });

    _showMessage('Maintenance task cancelled.', Colors.red);
  }

  // ============================================================
  // TECHNICIAN SELECTION
  // ============================================================

  void _showTechnicianSelection() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Technician',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._technicians.map(
                  (technician) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(technician),
                    trailing: _maintenanceItem.assignedTo == technician
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _maintenanceItem = _maintenanceItem.copyWith(
                          assignedTo: technician,
                        );
                      });

                      Navigator.pop(context);

                      _showMessage(
                        '$technician assigned successfully.',
                        AppColors.primary,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TECHNICIAN NOTES EDIT
  // ============================================================

  Future<void> _editTechnicianNotes() async {
    final controller = TextEditingController(
      text: _maintenanceItem.technicianNotes ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Technician Notes'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter technician notes...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(technicianNotes: result);
    });

    _showMessage('Technician notes updated.', AppColors.primary);
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
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
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return Colors.blue;
      case MaintenanceStatus.pending:
        return Colors.orange;
      case MaintenanceStatus.inProgress:
        return AppColors.primary;
      case MaintenanceStatus.completed:
        return Colors.green;
      case MaintenanceStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPriorityColor(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return Colors.green;
      case MaintenancePriority.medium:
        return Colors.blue;
      case MaintenancePriority.high:
        return Colors.orange;
      case MaintenancePriority.critical:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
