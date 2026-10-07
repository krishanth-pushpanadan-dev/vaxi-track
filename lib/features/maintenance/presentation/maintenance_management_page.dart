import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../data/maintenance_dummy_data.dart';
import '../model/maintenance_item_model.dart';
import '../presentation/report_maintenance_page.dart';
import '../presentation/maintenance_details_page.dart';

class MaintenanceManagementPage extends StatefulWidget {
  const MaintenanceManagementPage({super.key});

  @override
  State<MaintenanceManagementPage> createState() =>
      _MaintenanceManagementPageState();
}

class _MaintenanceManagementPageState extends State<MaintenanceManagementPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // LOCAL DATA
  // ============================================================

  late List<MaintenanceItem> _maintenanceItems;

  // ============================================================
  // SEARCH & FILTER
  // ============================================================

  String searchQuery = "";

  MaintenanceStatus? selectedStatus;
  MaintenancePriority? selectedPriority;
  MaintenanceType? selectedType;

  // ============================================================
  // ROLE CHECK
  // ============================================================

  bool get canViewMaintenance {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canViewMaintenance(user.role);
  }

  bool get canCreateMaintenance {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canCreateMaintenance(user.role);
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _maintenanceItems = List<MaintenanceItem>.from(maintenanceList);
  }

  // ============================================================
  // FILTERED ITEMS
  // ============================================================

  List<MaintenanceItem> get filteredMaintenanceItems {
    return _maintenanceItems.where((item) {
      final query = searchQuery.toLowerCase().trim();

      final matchesSearch =
          item.id.toLowerCase().contains(query) ||
          item.deviceName.toLowerCase().contains(query) ||
          item.deviceId.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.issueTitle.toLowerCase().contains(query);

      final matchesStatus =
          selectedStatus == null || item.status == selectedStatus;

      final matchesPriority =
          selectedPriority == null || item.priority == selectedPriority;

      final matchesType = selectedType == null || item.type == selectedType;

      return matchesSearch && matchesStatus && matchesPriority && matchesType;
    }).toList();
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  int get totalMaintenance => _maintenanceItems.length;

  int get pendingCount => _maintenanceItems
      .where((item) => item.status == MaintenanceStatus.pending)
      .length;

  int get inProgressCount => _maintenanceItems
      .where((item) => item.status == MaintenanceStatus.inProgress)
      .length;

  int get completedCount => _maintenanceItems
      .where((item) => item.status == MaintenanceStatus.completed)
      .length;

  int get criticalCount => _maintenanceItems
      .where((item) => item.priority == MaintenancePriority.critical)
      .length;

  int get overdueCount =>
      _maintenanceItems.where((item) => item.isOverdue).length;

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshMaintenance() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() {
      _maintenanceItems = List<MaintenanceItem>.from(maintenanceList);
    });
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
        return Colors.indigo;

      case MaintenanceStatus.completed:
        return Colors.green;

      case MaintenanceStatus.cancelled:
        return Colors.red;
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
        return Icons.build_circle_outlined;

      case MaintenanceType.corrective:
        return Icons.build_outlined;

      case MaintenanceType.calibration:
        return Icons.tune;

      case MaintenanceType.inspection:
        return Icons.fact_check_outlined;

      case MaintenanceType.emergency:
        return Icons.warning_amber_rounded;
    }
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 21),
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(MaintenanceStatus status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // PRIORITY CHIP
  // ============================================================

  Widget _buildPriorityChip(MaintenancePriority priority) {
    final color = _priorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _priorityLabel(priority),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  String _statusLabel(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return "Scheduled";

      case MaintenanceStatus.pending:
        return "Pending";

      case MaintenanceStatus.inProgress:
        return "In Progress";

      case MaintenanceStatus.completed:
        return "Completed";

      case MaintenanceStatus.cancelled:
        return "Cancelled";
    }
  }

  // ============================================================
  // PRIORITY LABEL
  // ============================================================

  String _priorityLabel(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return "Low";

      case MaintenancePriority.medium:
        return "Medium";

      case MaintenancePriority.high:
        return "High";

      case MaintenancePriority.critical:
        return "Critical";
    }
  }

  // ============================================================
  // DATE FORMATTER
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return "Not scheduled";
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ============================================================
  // OPEN MAINTENANCE DETAILS
  // ============================================================

  Future<void> _openMaintenanceDetails(MaintenanceItem item) async {
    final MaintenanceItem? updatedMaintenance =
        await Navigator.push<MaintenanceItem>(
          context,
          MaterialPageRoute(
            builder: (_) => MaintenanceDetailsPage(maintenanceItem: item),
          ),
        );

    if (updatedMaintenance == null || !mounted) {
      return;
    }

    final index = _maintenanceItems.indexWhere(
      (maintenance) => maintenance.id == updatedMaintenance.id,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      _maintenanceItems[index] = updatedMaintenance;
    });
  }

  // ============================================================
  // MAINTENANCE CARD
  // ============================================================

  Widget _buildMaintenanceCard(MaintenanceItem item) {
    final typeColor = _priorityColor(item.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        // ======================================================
        // UPDATED DETAILS NAVIGATION
        // ======================================================
        onTap: () {
          _openMaintenanceDetails(item);
        },

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // TOP ROW
              // ------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      _typeIcon(item.type),
                      color: typeColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.issueTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          item.deviceName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _buildStatusChip(item.status),
                ],
              ),

              const SizedBox(height: 15),

              // ------------------------------------------------
              // DEVICE / LOCATION
              // ------------------------------------------------
              _buildInfoRow(
                Icons.memory_outlined,
                item.deviceId,
                item.location,
              ),

              const SizedBox(height: 10),

              // ------------------------------------------------
              // TYPE / PRIORITY
              // ------------------------------------------------
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      item.typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  _buildPriorityChip(item.priority),
                ],
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // SCHEDULE
              // ------------------------------------------------
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    "Scheduled: ",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                  Text(
                    _formatDate(item.scheduledDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (item.isOverdue) ...[
                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "OVERDUE",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // ------------------------------------------------
              // ASSIGNED TECHNICIAN
              // ------------------------------------------------
              if (item.assignedTo != null) ...[
                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      "Assigned to: ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        item.assignedTo!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ------------------------------------------------
              // CRITICAL WARNING
              // ------------------------------------------------
              if (item.isCritical) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                        size: 18,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          "Critical maintenance requires immediate attention.",
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(IconData icon, String firstText, String secondText) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey.shade600),

        const SizedBox(width: 7),

        Text(
          firstText,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            secondText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER SHEET
  // ============================================================

  void _showFilterSheet() {
    MaintenanceStatus? tempStatus = selectedStatus;

    MaintenancePriority? tempPriority = selectedPriority;

    MaintenanceType? tempType = selectedType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Filter Maintenance",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MaintenanceStatus.values.map((status) {
                        return ChoiceChip(
                          label: Text(_statusLabel(status)),
                          selected: tempStatus == status,
                          onSelected: (selected) {
                            setSheetState(() {
                              tempStatus = selected ? status : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Priority",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MaintenancePriority.values.map((priority) {
                        return ChoiceChip(
                          label: Text(_priorityLabel(priority)),
                          selected: tempPriority == priority,
                          onSelected: (selected) {
                            setSheetState(() {
                              tempPriority = selected ? priority : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Maintenance Type",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MaintenanceType.values.map((type) {
                        return ChoiceChip(
                          label: Text(_typeLabel(type)),
                          selected: tempType == type,
                          onSelected: (selected) {
                            setSheetState(() {
                              tempType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedStatus = tempStatus;

                            selectedPriority = tempPriority;

                            selectedType = tempType;
                          });

                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TYPE LABEL
  // ============================================================

  String _typeLabel(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return "Preventive";

      case MaintenanceType.corrective:
        return "Corrective";

      case MaintenanceType.calibration:
        return "Calibration";

      case MaintenanceType.inspection:
        return "Inspection";

      case MaintenanceType.emergency:
        return "Emergency";
    }
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void _clearFilters() {
    setState(() {
      selectedStatus = null;
      selectedPriority = null;
      selectedType = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (!canViewMaintenance) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Maintenance Management"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("You do not have permission to view maintenance."),
        ),
      );
    }

    final items = filteredMaintenanceItems;

    final hasFilters =
        selectedStatus != null ||
        selectedPriority != null ||
        selectedType != null;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text("Maintenance Management"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        onRefresh: _refreshMaintenance,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            const Text(
              "Equipment Maintenance",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Monitor, schedule and manage IoT device maintenance.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SUMMARY ROW 1
            // ==================================================
            Row(
              children: [
                _buildSummaryCard(
                  title: "Total",
                  value: "$totalMaintenance",
                  icon: Icons.build_circle_outlined,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                _buildSummaryCard(
                  title: "Pending",
                  value: "$pendingCount",
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // SUMMARY ROW 2
            // ==================================================
            Row(
              children: [
                _buildSummaryCard(
                  title: "In Progress",
                  value: "$inProgressCount",
                  icon: Icons.engineering_outlined,
                  color: Colors.indigo,
                ),

                const SizedBox(width: 10),

                _buildSummaryCard(
                  title: "Completed",
                  value: "$completedCount",
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ALERT SUMMARY
            // ==================================================
            if (criticalCount > 0 || overdueCount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100),
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
                        "$criticalCount critical case(s) • "
                        "$overdueCount overdue case(s)",
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // SEARCH
            // ==================================================
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search maintenance, device or location...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            searchQuery = "";
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // FILTER BUTTON
            // ==================================================
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filters"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (hasFilters) ...[
                  const SizedBox(width: 10),

                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text("Clear"),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 18),

            // ==================================================
            // RESULTS HEADER
            // ==================================================
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Maintenance Records",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Text(
                  "${items.length} record(s)",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // EMPTY STATE
            // ==================================================
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 55,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "No maintenance records found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Try changing your search or filters.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...items.map(_buildMaintenanceCard),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ========================================================
      // FAB
      // ========================================================
      floatingActionButton: canCreateMaintenance
          ? FloatingActionButton.extended(
              onPressed: () async {
                final MaintenanceItem? newMaintenance =
                    await Navigator.push<MaintenanceItem>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportMaintenancePage(),
                      ),
                    );

                if (newMaintenance == null || !mounted) {
                  return;
                }

                setState(() {
                  _maintenanceItems.insert(0, newMaintenance);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance report submitted successfully.'),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text("Report Maintenance"),
            )
          : null,
    );
  }
}
