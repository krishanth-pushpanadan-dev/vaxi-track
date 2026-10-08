import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/maintenance_item_model.dart';

class ReportMaintenancePage extends StatefulWidget {
  const ReportMaintenancePage({super.key});

  @override
  State<ReportMaintenancePage> createState() => _ReportMaintenancePageState();
}

class _ReportMaintenancePageState extends State<ReportMaintenancePage> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController _issueTitleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _costController = TextEditingController();

  MaintenanceType _selectedType = MaintenanceType.corrective;

  MaintenancePriority _selectedPriority = MaintenancePriority.medium;

  String? _selectedDevice;
  DateTime? _scheduledDate;

  bool _isSubmitting = false;

  final List<Map<String, String>> _devices = [
    {
      'id': 'DEV-001',
      'name': 'ESP32 Cold Box A',
      'location': 'Colombo General Hospital',
    },
    {
      'id': 'DEV-002',
      'name': 'ESP32 Cold Box B',
      'location': 'Kandy Regional Hospital',
    },
    {
      'id': 'DEV-003',
      'name': 'ESP32 Cold Box C',
      'location': 'Jaffna MOH Office',
    },
    {
      'id': 'DEV-004',
      'name': 'ESP32 Vaccine Transport Unit',
      'location': 'Central Warehouse',
    },
    {
      'id': 'DEV-005',
      'name': 'ESP32 Cold Storage Unit',
      'location': 'Galle Hospital',
    },
    {
      'id': 'DEV-006',
      'name': 'ESP32 Cold Box D',
      'location': 'Kurunegala Hospital',
    },
  ];

  @override
  void dispose() {
    _issueTitleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  bool get _canCreateMaintenance {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canCreateMaintenance(user.role);
  }

  Map<String, String>? get _selectedDeviceData {
    if (_selectedDevice == null) {
      return null;
    }

    try {
      return _devices.firstWhere((device) => device['id'] == _selectedDevice);
    } catch (_) {
      return null;
    }
  }

  String _typeLabel(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventive';
      case MaintenanceType.corrective:
        return 'Corrective';
      case MaintenanceType.calibration:
        return 'Calibration';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.emergency:
        return 'Emergency';
    }
  }

  String _priorityLabel(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return 'Low';
      case MaintenancePriority.medium:
        return 'Medium';
      case MaintenancePriority.high:
        return 'High';
      case MaintenancePriority.critical:
        return 'Critical';
    }
  }

  Future<void> _selectScheduledDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _scheduledDate = picked;
    });
  }

  void _clearScheduledDate() {
    setState(() {
      _scheduledDate = null;
    });
  }

  Future<void> _submitMaintenance() async {
    if (!_canCreateMaintenance) {
      _showMessage(
        'You do not have permission to report maintenance.',
        isError: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDevice == null) {
      _showMessage('Please select a device.', isError: true);
      return;
    }

    final user = _authService.currentUser;

    if (user == null) {
      _showMessage('No logged-in user found.', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final device = _selectedDeviceData;

    final double? maintenanceCost = _costController.text.trim().isEmpty
        ? null
        : double.tryParse(_costController.text.trim());

    final bool requiresReview = !RolePermissions.canManageMaintenance(
      user.role,
    );

    final MaintenanceItem newMaintenance = MaintenanceItem(
      id: 'MNT-${DateTime.now().millisecondsSinceEpoch}',
      deviceId: device?['id'] ?? '',
      deviceName: device?['name'] ?? '',
      location: device?['location'] ?? '',
      type: _selectedType,
      priority: _selectedPriority,
      status: _scheduledDate != null
          ? MaintenanceStatus.scheduled
          : MaintenanceStatus.pending,

      approvalStatus: MaintenanceApprovalStatus.pending,
      issueTitle: _issueTitleController.text.trim(),
      description: _descriptionController.text.trim(),
      reportedBy: user.name,
      reportedByRole: _roleLabel(user.role),
      assignedTo: null,
      reportedDate: DateTime.now(),
      scheduledDate: _scheduledDate,
      completedDate: null,
      technicianNotes: null,
      maintenanceCost: maintenanceCost,
      requiresReview: requiresReview,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pop(context, newMaintenance);
  }

  String _roleLabel(dynamic role) {
    final roleString = role.toString();

    if (roleString.contains('admin')) {
      return 'Admin';
    }

    if (roleString.contains('warehouse')) {
      return 'Warehouse Staff';
    }

    if (roleString.contains('facility')) {
      return 'Facility Staff';
    }

    if (roleString.contains('pharmacist')) {
      return 'Pharmacist';
    }

    if (roleString.contains('sales')) {
      return 'Sales Representative';
    }

    return roleString;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (!_canCreateMaintenance) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Maintenance')),
        body: const Center(
          child: Text('You do not have permission to report maintenance.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Maintenance'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(),

              const SizedBox(height: 24),

              _buildSectionTitle('Device Information', Icons.devices_rounded),

              const SizedBox(height: 12),

              _buildDeviceDropdown(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Maintenance Details',
                Icons.build_circle_rounded,
              ),

              const SizedBox(height: 12),

              _buildIssueTitleField(),

              const SizedBox(height: 16),

              _buildTypeDropdown(),

              const SizedBox(height: 16),

              _buildPriorityDropdown(),

              const SizedBox(height: 16),

              _buildDescriptionField(),

              const SizedBox(height: 24),

              _buildSectionTitle('Scheduling', Icons.calendar_month_rounded),

              const SizedBox(height: 12),

              _buildScheduledDateField(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Additional Information',
                Icons.info_outline_rounded,
              ),

              const SizedBox(height: 12),

              _buildCostField(),

              const SizedBox(height: 20),

              _buildReporterCard(user),

              const SizedBox(height: 28),

              _buildSubmitButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.build_circle_rounded, color: Colors.white, size: 38),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Maintenance Issue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Report a device issue or schedule maintenance.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDeviceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDevice,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Select Device',
        prefixIcon: const Icon(Icons.devices_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: _devices.map((device) {
        return DropdownMenuItem<String>(
          value: device['id'],
          child: Text(
            '${device['name']} (${device['id']})',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDevice = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a device';
        }
        return null;
      },
    );
  }

  Widget _buildIssueTitleField() {
    return TextFormField(
      controller: _issueTitleController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Issue Title',
        hintText: 'e.g. Temperature Sensor Reading Issue',
        prefixIcon: const Icon(Icons.title_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an issue title';
        }

        if (value.trim().length < 5) {
          return 'Issue title is too short';
        }

        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<MaintenanceType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: 'Maintenance Type',
        prefixIcon: const Icon(Icons.build_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: MaintenanceType.values.map((type) {
        return DropdownMenuItem<MaintenanceType>(
          value: type,
          child: Text(_typeLabel(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedType = value;
        });
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<MaintenancePriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priority',
        prefixIcon: const Icon(Icons.flag_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: MaintenancePriority.values.map((priority) {
        return DropdownMenuItem<MaintenancePriority>(
          value: priority,
          child: Text(_priorityLabel(priority)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedPriority = value;
        });
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe the maintenance issue or required work...',
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 80),
          child: Icon(Icons.description_rounded),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please describe the maintenance issue';
        }

        if (value.trim().length < 10) {
          return 'Please provide more details';
        }

        return null;
      },
    );
  }

  Widget _buildScheduledDateField() {
    return InkWell(
      onTap: _selectScheduledDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Scheduled Date',
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          suffixIcon: _scheduledDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearScheduledDate,
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          _scheduledDate == null
              ? 'Select a date (optional)'
              : '${_scheduledDate!.day.toString().padLeft(2, '0')}/'
                    '${_scheduledDate!.month.toString().padLeft(2, '0')}/'
                    '${_scheduledDate!.year}',
          style: TextStyle(
            color: _scheduledDate == null ? Colors.grey.shade600 : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: _costController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Estimated Maintenance Cost',
        hintText: 'Optional',
        prefixText: 'Rs. ',
        prefixIcon: const Icon(Icons.payments_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }

        final cost = double.tryParse(value.trim());

        if (cost == null || cost < 0) {
          return 'Enter a valid cost';
        }

        return null;
      },
    );
  }

  Widget _buildReporterCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: const Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reported By',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.name ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _roleLabel(user?.role),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitMaintenance,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(
          _isSubmitting ? 'Submitting...' : 'Submit Maintenance Report',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
