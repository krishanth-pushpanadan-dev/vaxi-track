import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/maintenance_item_model.dart';

class MaintenanceDetailsPage extends StatefulWidget {
  final MaintenanceItem maintenanceItem;

  const MaintenanceDetailsPage({super.key, required this.maintenanceItem});

  @override
  State<MaintenanceDetailsPage> createState() => _MaintenanceDetailsPageState();
}

class _MaintenanceDetailsPageState extends State<MaintenanceDetailsPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // LOCAL DATA
  // ============================================================

  late MaintenanceItem _maintenanceItem;

  // ============================================================
  // TECHNICIANS
  // ============================================================

  final List<String> _technicians = [
    'Nuwan Silva',
    'Kasun Perera',
    'Ravindu Fernando',
    'Chamod Jayasinghe',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _maintenanceItem = widget.maintenanceItem;
  }

  // ============================================================
  // ROLE CHECK
  // ============================================================

  bool get _canManageMaintenance {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canManageMaintenance(user.role);
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return Colors.blue;

      case MaintenanceStatus.pending:
        return Colors.orange;

      case MaintenanceStatus.inProgress:
        return Colors.deepPurple;

      case MaintenanceStatus.completed:
        return Colors.green;

      case MaintenanceStatus.cancelled:
        return Colors.grey;
    }
  }

  // ============================================================
  // PRIORITY COLOR
  // ============================================================

  Color _priorityColor(MaintenancePriority priority) {
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

  // ============================================================
  // TYPE ICON
  // ============================================================

  IconData _typeIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return Icons.event_repeat_rounded;

      case MaintenanceType.corrective:
        return Icons.build_rounded;

      case MaintenanceType.calibration:
        return Icons.tune_rounded;

      case MaintenanceType.inspection:
        return Icons.search_rounded;

      case MaintenanceType.emergency:
        return Icons.warning_rounded;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not specified';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return 'Not specified';
    }

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '${_formatDate(date)} $hour:$minute';
  }

  // ============================================================
  // RETURN UPDATED ITEM
  // ============================================================

  void _goBackWithResult() {
    Navigator.pop(context, _maintenanceItem);
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> _updateStatus(MaintenanceStatus newStatus) async {
    if (!_canManageMaintenance) {
      _showMessage(
        'You do not have permission to manage maintenance.',
        isError: true,
      );
      return;
    }

    String actionText;

    switch (newStatus) {
      case MaintenanceStatus.inProgress:
        actionText = 'start this maintenance task';
        break;

      case MaintenanceStatus.completed:
        actionText = 'mark this maintenance as completed';
        break;

      case MaintenanceStatus.cancelled:
        actionText = 'cancel this maintenance task';
        break;

      default:
        actionText = 'update this maintenance';
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: Text('Are you sure you want to $actionText?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final DateTime? completedDate = newStatus == MaintenanceStatus.completed
        ? DateTime.now()
        : _maintenanceItem.completedDate;

    final MaintenanceItem updatedItem = _maintenanceItem.copyWith(
      status: newStatus,
      completedDate: completedDate,
      requiresReview: false,
    );

    setState(() {
      _maintenanceItem = updatedItem;
    });

    if (!mounted) {
      return;
    }

    _showMessage('Maintenance status updated successfully.');
  }

  // ============================================================
  // ASSIGN TECHNICIAN
  // ============================================================

  Future<void> _assignTechnician() async {
    if (!_canManageMaintenance) {
      _showMessage(
        'You do not have permission to assign technicians.',
        isError: true,
      );
      return;
    }

    String? selectedTechnician = _maintenanceItem.assignedTo;

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.engineering_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Assign Technician'),
                ],
              ),
              content: DropdownButtonFormField<String>(
                value: selectedTechnician,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Technician',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _technicians.map((technician) {
                  return DropdownMenuItem<String>(
                    value: technician,
                    child: Text(technician),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedTechnician = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedTechnician == null
                      ? null
                      : () {
                          Navigator.pop(dialogContext, selectedTechnician);
                        },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        assignedTo: result,
        requiresReview: false,
      );
    });

    _showMessage('$result has been assigned successfully.');
  }

  // ============================================================
  // EDIT TECHNICIAN NOTES
  // ============================================================

  Future<void> _editTechnicianNotes() async {
    if (!_canManageMaintenance) {
      _showMessage(
        'You do not have permission to update technician notes.',
        isError: true,
      );
      return;
    }

    final controller = TextEditingController(
      text: _maintenanceItem.technicianNotes ?? '',
    );

    final String? notes = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notes_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Technician Notes'),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Enter maintenance notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (notes == null) {
      return;
    }

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        technicianNotes: notes.isEmpty ? null : notes,
      );
    });

    _showMessage('Technician notes updated.');
  }

  // ============================================================
  // EDIT MAINTENANCE COST
  // ============================================================

  Future<void> _editMaintenanceCost() async {
    if (!_canManageMaintenance) {
      _showMessage(
        'You do not have permission to update maintenance cost.',
        isError: true,
      );
      return;
    }

    final controller = TextEditingController(
      text: _maintenanceItem.maintenanceCost?.toStringAsFixed(2) ?? '',
    );

    final String? cost = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.payments_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Maintenance Cost'),
            ],
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Cost in LKR',
              prefixText: 'Rs. ',
              hintText: '2500.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (cost == null) {
      return;
    }

    final double? parsedCost = double.tryParse(cost);

    if (cost.isNotEmpty && parsedCost == null) {
      _showMessage('Please enter a valid cost.', isError: true);
      return;
    }

    setState(() {
      _maintenanceItem = _maintenanceItem.copyWith(
        maintenanceCost: cost.isEmpty ? null : parsedCost,
      );
    });

    _showMessage('Maintenance cost updated.');
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final item = _maintenanceItem;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        Navigator.pop(context, _maintenanceItem);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance Details'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackWithResult,
          ),
        ),

        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ==================================================
              // HEADER
              // ==================================================
              _buildHeader(item),

              const SizedBox(height: 20),

              // ==================================================
              // STATUS
              // ==================================================
              _buildStatusSection(item),

              const SizedBox(height: 20),

              // ==================================================
              // DEVICE INFORMATION
              // ==================================================
              _buildSection(
                title: 'Device Information',
                icon: Icons.devices_rounded,
                children: [
                  _buildInfoRow(
                    'Device',
                    item.deviceName,
                    Icons.memory_rounded,
                  ),
                  _buildInfoRow('Device ID', item.deviceId, Icons.tag_rounded),
                  _buildInfoRow(
                    'Location',
                    item.location,
                    Icons.location_on_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MAINTENANCE INFORMATION
              // ==================================================
              _buildSection(
                title: 'Maintenance Information',
                icon: Icons.build_circle_rounded,
                children: [
                  _buildInfoRow(
                    'Issue',
                    item.issueTitle,
                    Icons.report_problem_rounded,
                  ),
                  _buildInfoRow('Type', item.typeLabel, _typeIcon(item.type)),
                  _buildInfoRow(
                    'Priority',
                    item.priorityLabel,
                    Icons.flag_rounded,
                  ),
                  _buildInfoRow(
                    'Reported Date',
                    _formatDateTime(item.reportedDate),
                    Icons.calendar_today_rounded,
                  ),
                  _buildInfoRow(
                    'Scheduled Date',
                    _formatDate(item.scheduledDate),
                    Icons.event_rounded,
                  ),
                  _buildInfoRow(
                    'Completed Date',
                    _formatDateTime(item.completedDate),
                    Icons.check_circle_outline_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DESCRIPTION
              // ==================================================
              _buildSection(
                title: 'Description',
                icon: Icons.description_rounded,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.description,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // ASSIGNMENT
              // ==================================================
              _buildAssignmentSection(item),

              const SizedBox(height: 16),

              // ==================================================
              // ADDITIONAL INFORMATION
              // ==================================================
              _buildAdditionalInformation(item),

              const SizedBox(height: 16),

              // ==================================================
              // TECHNICIAN NOTES
              // ==================================================
              _buildTechnicianNotes(item),

              // ==================================================
              // OVERDUE WARNING
              // ==================================================
              if (item.isOverdue) ...[
                const SizedBox(height: 16),
                _buildOverdueWarning(),
              ],

              // ==================================================
              // MANAGEMENT ACTIONS
              // ==================================================
              if (_canManageMaintenance) ...[
                const SizedBox(height: 24),
                _buildManagementActions(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(MaintenanceItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_typeIcon(item.type), color: Colors.white, size: 30),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.issueTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.id,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS SECTION
  // ============================================================

  Widget _buildStatusSection(MaintenanceItem item) {
    final statusColor = _statusColor(item.status);

    final priorityColor = _priorityColor(item.priority);

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            title: 'Status',
            value: item.statusLabel,
            color: statusColor,
            icon: Icons.sync_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            title: 'Priority',
            value: item.priorityLabel,
            color: priorityColor,
            icon: Icons.flag_rounded,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT SECTION
  // ============================================================

  Widget _buildAssignmentSection(MaintenanceItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.engineering_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Assignment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              if (_canManageMaintenance)
                IconButton(
                  onPressed: _assignTechnician,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Assign technician',
                ),
            ],
          ),

          const SizedBox(height: 14),

          _buildInfoRow('Reported By', item.reportedBy, Icons.person_rounded),

          _buildInfoRow(
            'Reporter Role',
            item.reportedByRole,
            Icons.badge_rounded,
          ),

          _buildInfoRow(
            'Technician',
            item.assignedTo ?? 'Not assigned',
            Icons.engineering_rounded,
          ),

          if (_canManageMaintenance) ...[
            const SizedBox(height: 4),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _assignTechnician,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(
                  item.assignedTo == null
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

  Widget _buildAdditionalInformation(MaintenanceItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Additional Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildInfoRow(
            'Cost',
            item.maintenanceCost == null
                ? 'Not specified'
                : 'Rs. ${item.maintenanceCost!.toStringAsFixed(2)}',
            Icons.payments_rounded,
          ),

          _buildInfoRow(
            'Requires Review',
            item.requiresReview ? 'Yes' : 'No',
            item.requiresReview
                ? Icons.warning_rounded
                : Icons.verified_rounded,
          ),

          if (_canManageMaintenance)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editMaintenanceCost,
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  item.maintenanceCost == null
                      ? 'Add Maintenance Cost'
                      : 'Edit Maintenance Cost',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TECHNICIAN NOTES
  // ============================================================

  Widget _buildTechnicianNotes(MaintenanceItem item) {
    final hasNotes =
        item.technicianNotes != null && item.technicianNotes!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes_rounded,
                color: AppColors.primary,
                size: 20,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Technician Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              if (_canManageMaintenance)
                IconButton(
                  onPressed: _editTechnicianNotes,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit notes',
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (hasNotes)
            Text(
              item.technicianNotes!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            )
          else
            Text(
              'No technician notes have been added yet.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),

          if (_canManageMaintenance) ...[
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editTechnicianNotes,
                icon: const Icon(Icons.note_add_outlined),
                label: Text(hasNotes ? 'Edit Notes' : 'Add Technician Notes'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
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

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Colors.grey.shade600),

          const SizedBox(width: 10),

          SizedBox(
            width: 115,
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

  // ============================================================
  // OVERDUE WARNING
  // ============================================================

  Widget _buildOverdueWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.20)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This maintenance task is overdue and requires attention.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
    final status = _maintenanceItem.status;

    if (status == MaintenanceStatus.completed ||
        status == MaintenanceStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maintenance Actions',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // START
        // ------------------------------------------------------
        if (status == MaintenanceStatus.pending ||
            status == MaintenanceStatus.scheduled)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _updateStatus(MaintenanceStatus.inProgress);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Maintenance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

        // ------------------------------------------------------
        // COMPLETE
        // ------------------------------------------------------
        if (status == MaintenanceStatus.inProgress)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _updateStatus(MaintenanceStatus.completed);
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // CANCEL
        // ------------------------------------------------------
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _updateStatus(MaintenanceStatus.cancelled);
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel Maintenance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
