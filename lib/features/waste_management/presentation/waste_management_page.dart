import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../model/waste_item_model.dart';
import '../presentation/report_waste_page.dart';
import '../presentation/waste_details_page.dart';

class WasteManagementPage extends StatefulWidget {
  const WasteManagementPage({super.key});

  @override
  State<WasteManagementPage> createState() => _WasteManagementPageState();
}

class _WasteManagementPageState extends State<WasteManagementPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final AuthService _authService = AuthService();

  // ============================================================
  // CURRENT USER / ROLE
  // ============================================================

  bool get canApproveWaste {
    final user = _authService.currentUser;

    if (user == null) {
      return false;
    }

    return RolePermissions.canApproveWaste(user.role);
  }

  // ============================================================
  // MOCK DATA
  // ============================================================

  final List<WasteItem> _wasteItems = [
    WasteItem(
      id: "WST-001",
      medicineName: "Pfizer COVID-19 Vaccine",
      batchNumber: "PFZ2026A23",
      quantity: 25,
      unit: "doses",
      reason: WasteReason.expired,
      status: WasteStatus.pending,
      reportedBy: "Kamal Perera",
      reportedByRole: "Warehouse Staff",
      description: "Vaccines reached their expiry date.",
      imagePath: "",
      reportedDate: DateTime(2026, 8, 10),
      expiryDate: DateTime(2026, 8, 5),
      location: "Central Warehouse",
      requiresReview: true,
    ),
    WasteItem(
      id: "WST-002",
      medicineName: "Paracetamol 500mg",
      batchNumber: "PCM2026B12",
      quantity: 100,
      unit: "tablets",
      reason: WasteReason.damaged,
      status: WasteStatus.pending,
      reportedBy: "Nimal Silva",
      reportedByRole: "Pharmacist",
      description: "Several medicine packages were physically damaged.",
      imagePath: "",
      reportedDate: DateTime(2026, 8, 12),
      expiryDate: DateTime(2027, 3, 15),
      location: "Kandy Teaching Hospital",
      requiresReview: true,
    ),
    WasteItem(
      id: "WST-003",
      medicineName: "Insulin Injection",
      batchNumber: "INS2026C08",
      quantity: 15,
      unit: "vials",
      reason: WasteReason.temperatureExcursion,
      status: WasteStatus.approved,
      reportedBy: "Suresh Kumar",
      reportedByRole: "Facility Staff",
      description: "Storage temperature exceeded the recommended range.",
      imagePath: "",
      reportedDate: DateTime(2026, 8, 8),
      expiryDate: DateTime(2027, 1, 20),
      location: "Jaffna Hospital",
      requiresReview: false,
    ),
    WasteItem(
      id: "WST-004",
      medicineName: "AstraZeneca Vaccine",
      batchNumber: "AZ2026D45",
      quantity: 40,
      unit: "doses",
      reason: WasteReason.expired,
      status: WasteStatus.approved,
      reportedBy: "Kamal Perera",
      reportedByRole: "Warehouse Staff",
      description:
          "Expired vaccine stock identified during inventory inspection.",
      imagePath: "",
      reportedDate: DateTime(2026, 8, 2),
      expiryDate: DateTime(2026, 7, 30),
      location: "Central Warehouse",
      requiresReview: false,
    ),
    WasteItem(
      id: "WST-005",
      medicineName: "Amoxicillin 500mg",
      batchNumber: "AMX2026E19",
      quantity: 60,
      unit: "capsules",
      reason: WasteReason.damaged,
      status: WasteStatus.rejected,
      reportedBy: "Suresh Kumar",
      reportedByRole: "Facility Staff",
      description: "Waste report rejected after inspection.",
      imagePath: "",
      reportedDate: DateTime(2026, 7, 28),
      expiryDate: DateTime(2027, 5, 10),
      location: "Galle Hospital",
      requiresReview: false,
    ),
  ];

  // ============================================================
  // SEARCH / FILTER
  // ============================================================

  String searchQuery = "";

  WasteStatus? selectedStatus;

  WasteReason? selectedReason;

  List<WasteItem> get filteredWasteItems {
    return _wasteItems.where((item) {
      final query = searchQuery.toLowerCase().trim();

      final matchesSearch =
          item.medicineName.toLowerCase().contains(query) ||
          item.batchNumber.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);

      final matchesStatus =
          selectedStatus == null || item.status == selectedStatus;

      final matchesReason =
          selectedReason == null || item.reason == selectedReason;

      return matchesSearch && matchesStatus && matchesReason;
    }).toList();
  }

  // ============================================================
  // SUMMARY COUNTS
  // ============================================================

  int get totalWaste => _wasteItems.length;

  int get pendingCount {
    return _wasteItems
        .where((item) => item.status == WasteStatus.pending)
        .length;
  }

  int get approvedCount {
    return _wasteItems
        .where((item) => item.status == WasteStatus.approved)
        .length;
  }

  int get expiredCount {
    return _wasteItems
        .where((item) => item.reason == WasteReason.expired)
        .length;
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(WasteStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case WasteStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = "Pending";
        break;

      case WasteStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = "Approved";
        break;

      case WasteStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = "Rejected";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // REASON CHIP
  // ============================================================

  Widget _buildReasonChip(WasteReason reason) {
    IconData icon;
    String label;

    switch (reason) {
      case WasteReason.expired:
        icon = Icons.event_busy;
        label = "Expired";
        break;

      case WasteReason.damaged:
        icon = Icons.broken_image_outlined;
        label = "Damaged";
        break;

      case WasteReason.temperatureExcursion:
        icon = Icons.thermostat;
        label = "Temperature Excursion";
        break;

      case WasteReason.contaminated:
        icon = Icons.warning_amber;
        label = "Contaminated";
        break;

      case WasteReason.other:
        icon = Icons.more_horiz;
        label = "Other";
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WASTE CARD
  // ============================================================

  Widget _buildWasteCard(WasteItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        // Open the dedicated details page.
        onTap: () => _openWasteDetails(item),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.reason == WasteReason.expired
                          ? Icons.event_busy
                          : Icons.medication_outlined,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.medicineName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Batch: ${item.batchNumber}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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

              _buildReasonChip(item.reason),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.inventory_2_outlined,
                      "Quantity",
                      "${item.quantity} ${item.unit}",
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on_outlined,
                      "Location",
                      item.location,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Reported by ${item.reportedBy}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER SHEET
  // ============================================================

  void _showFilterSheet() {
    WasteStatus? tempStatus = selectedStatus;
    WasteReason? tempReason = selectedReason;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Filter Waste Cases",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: WasteStatus.values.map((status) {
                      final selected = tempStatus == status;

                      return ChoiceChip(
                        label: Text(
                          status == WasteStatus.pending
                              ? "Pending"
                              : status == WasteStatus.approved
                              ? "Approved"
                              : "Rejected",
                        ),
                        selected: selected,
                        onSelected: (_) {
                          setModalState(() {
                            tempStatus = selected ? null : status;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Waste Reason",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: WasteReason.values.map((reason) {
                      final selected = tempReason == reason;

                      return ChoiceChip(
                        label: Text(
                          reason == WasteReason.expired
                              ? "Expired"
                              : reason == WasteReason.damaged
                              ? "Damaged"
                              : reason == WasteReason.temperatureExcursion
                              ? "Temperature"
                              : reason == WasteReason.contaminated
                              ? "Contaminated"
                              : "Other",
                        ),
                        selected: selected,
                        onSelected: (_) {
                          setModalState(() {
                            tempReason = selected ? null : reason;
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
                          selectedReason = tempReason;
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // OPEN WASTE DETAILS PAGE
  // ============================================================

  Future<void> _openWasteDetails(WasteItem item) async {
    final result = await Navigator.push<WasteItem>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return WasteDetailsPage(wasteItem: item);
        },
      ),
    );

    if (result != null && mounted) {
      final index = _wasteItems.indexWhere(
        (element) => element.id == result.id,
      );

      if (index != -1) {
        setState(() {
          _wasteItems[index] = result;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final items = filteredWasteItems;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text("Waste Management"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));

          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            const Text(
              "Medicine Waste",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Monitor, report and review pharmaceutical waste.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SUMMARY CARDS
            // ==================================================
            Row(
              children: [
                _buildSummaryCard(
                  "Total Waste",
                  "$totalWaste",
                  Icons.delete_outline,
                ),
                const SizedBox(width: 10),
                _buildSummaryCard(
                  "Pending Review",
                  "$pendingCount",
                  Icons.pending_actions,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _buildSummaryCard(
                  "Approved",
                  "$approvedCount",
                  Icons.check_circle_outline,
                ),
                const SizedBox(width: 10),
                _buildSummaryCard("Expired", "$expiredCount", Icons.event_busy),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SEARCH
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search medicine, batch or case...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: _showFilterSheet,
                    icon: Icon(Icons.filter_list, color: AppColors.primary),
                  ),
                ),
              ],
            ),

            // ==================================================
            // ACTIVE FILTERS
            // ==================================================
            if (selectedStatus != null || selectedReason != null) ...[
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  if (selectedStatus != null)
                    Chip(
                      label: Text(
                        selectedStatus == WasteStatus.pending
                            ? "Pending"
                            : selectedStatus == WasteStatus.approved
                            ? "Approved"
                            : "Rejected",
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedStatus = null;
                        });
                      },
                    ),

                  if (selectedReason != null)
                    Chip(
                      label: Text(
                        selectedReason == WasteReason.expired
                            ? "Expired"
                            : selectedReason == WasteReason.damaged
                            ? "Damaged"
                            : selectedReason == WasteReason.temperatureExcursion
                            ? "Temperature"
                            : selectedReason == WasteReason.contaminated
                            ? "Contaminated"
                            : "Other",
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedReason = null;
                        });
                      },
                    ),
                ],
              ),
            ],

            const SizedBox(height: 25),

            // ==================================================
            // SECTION HEADER
            // ==================================================
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Waste Cases",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "${items.length} cases",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // WASTE LIST
            // ==================================================
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No waste cases found",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Try changing your search or filters.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...items.map(_buildWasteCard),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ========================================================
      // REPORT WASTE BUTTON
      // ========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<WasteItem>(
            context,
            MaterialPageRoute(builder: (_) => const ReportWastePage()),
          );

          if (result != null && mounted) {
            setState(() {
              _wasteItems.insert(0, result);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Waste report added successfully.")),
            );
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Report Waste"),
      ),
    );
  }
}
