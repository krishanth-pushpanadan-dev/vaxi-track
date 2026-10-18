import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../app/app_colors.dart';
import '../../alerts/data/alert_dummy_data.dart';
import '../../alerts/models/alert_model.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../../maintenance/data/maintenance_dummy_data.dart';
import '../../maintenance/model/maintenance_item_model.dart';
import '../../vaccine_batches/data/batch_dummy_data.dart';
import '../../vaccine_batches/models/batch_model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const List<String> _reportTypes = [
    'Cold-chain compliance',
    'Alerts summary',
    'Vaccine batches & expiry',
    'Maintenance summary',
  ];

  String _selectedReport = _reportTypes.first;
  DateTimeRange? _dateRange;
  bool _reportGenerated = false;

  int get _activeAlerts =>
      alertList.where((item) => item.status == AlertStatus.active).length;

  int get _criticalAlerts => alertList
      .where(
        (item) =>
            item.status == AlertStatus.active &&
            item.severity == AlertSeverity.critical,
      )
      .length;

  int get _activeBatches =>
      batchList.where((item) => item.status != BatchStatus.expired).length;

  int get _totalDoses =>
      batchList.fold<int>(0, (sum, item) => sum + item.quantity);

  int get _completedMaintenance => maintenanceList
      .where((item) => item.status == MaintenanceStatus.completed)
      .length;

  int get _openMaintenance => maintenanceList
      .where(
        (item) =>
            item.status != MaintenanceStatus.completed &&
            item.status != MaintenanceStatus.cancelled,
      )
      .length;

  Future<void> _chooseDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month, now.day),
          ),
      helpText: 'Select report period',
    );
    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
        _reportGenerated = false;
      });
    }
  }

  String get _periodLabel {
    if (_dateRange == null) return 'All available sample records';
    final start = _dateRange!.start;
    final end = _dateRange!.end;
    return '${_formatDate(start)} – ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _buildCsv() {
    final rows = <List<String>>[
      ['VaxiTrack Sri Lanka - $_selectedReport'],
      ['Report period', _periodLabel],
      ['Generated on', _formatDate(DateTime.now())],
      [],
    ];

    switch (_selectedReport) {
      case 'Cold-chain compliance':
        rows.add(['Metric', 'Value']);
        rows.addAll([
          ['Illustrative compliance rate', '96%'],
          ['Safe storage range', '2°C–8°C'],
          ['Active alerts in sample data', '$_activeAlerts'],
          ['Critical active alerts', '$_criticalAlerts'],
        ]);
        break;
      case 'Alerts summary':
        rows.add([
          'Alert ID',
          'Title',
          'Device',
          'Location',
          'Severity',
          'Status',
          'Acknowledged',
        ]);
        for (final alert in alertList) {
          rows.add([
            alert.id,
            alert.title,
            alert.deviceName,
            alert.location,
            alert.severityText,
            alert.statusText,
            alert.acknowledged ? 'Yes' : 'No',
          ]);
        }
        break;
      case 'Vaccine batches & expiry':
        rows.add([
          'Batch ID',
          'Vaccine',
          'Batch Number',
          'Quantity',
          'Location',
          'Expiry Date',
          'Status',
        ]);
        for (final batch in batchList) {
          rows.add([
            batch.id,
            batch.vaccineName,
            batch.batchNumber,
            '${batch.quantity}',
            batch.location,
            batch.expiryDate,
            batch.statusText,
          ]);
        }
        break;
      case 'Maintenance summary':
        rows.add([
          'Maintenance ID',
          'Issue',
          'Device',
          'Location',
          'Type',
          'Priority',
          'Status',
          'Assigned To',
        ]);
        for (final item in maintenanceList) {
          rows.add([
            item.id,
            item.issueTitle,
            item.deviceName,
            item.location,
            item.typeLabel,
            item.priorityLabel,
            item.statusLabel,
            item.assignedTo ?? 'Unassigned',
          ]);
        }
        break;
    }

    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return (escaped.contains(',') ||
            escaped.contains('"') ||
            escaped.contains('\n'))
        ? '"$escaped"'
        : escaped;
  }

  Future<void> _exportCsv() async {
    await Clipboard.setData(ClipboardData(text: _buildCsv()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'CSV report copied. Paste it into a spreadsheet or text file.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generateReport() {
    setState(() => _reportGenerated = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Report preview updated using the available sample data.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null || !RolePermissions.canViewReports(user.role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports & Analytics')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('You do not have permission to view reports.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh report data',
            onPressed: () => setState(() => _reportGenerated = false),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            _buildIntroCard(),
            const SizedBox(height: 18),
            _sectionTitle('System overview', 'Based on current sample records'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.48,
              children: [
                _metricCard(
                  'Compliance',
                  '96%',
                  'Illustrative sample',
                  Icons.verified_rounded,
                  const Color(0xFF198754),
                ),
                _metricCard(
                  'Active alerts',
                  '$_activeAlerts',
                  '$_criticalAlerts critical',
                  Icons.notifications_active_rounded,
                  AppColors.danger,
                ),
                _metricCard(
                  'Active batches',
                  '$_activeBatches',
                  '$_totalDoses total doses',
                  Icons.inventory_2_rounded,
                  AppColors.primary,
                ),
                _metricCard(
                  'Maintenance open',
                  '$_openMaintenance',
                  '$_completedMaintenance completed',
                  Icons.build_circle_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _sectionTitle(
              'Compliance trend',
              'Illustrative weekly sample values',
            ),
            const SizedBox(height: 12),
            _buildComplianceChart(),
            const SizedBox(height: 22),
            _sectionTitle(
              'Generate a report',
              'Choose a report type and period',
            ),
            const SizedBox(height: 12),
            _buildReportControls(),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.assessment_rounded),
                label: const Text('Generate report preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_reportGenerated) ...[
              const SizedBox(height: 16),
              _buildReportPreview(),
            ],
            const SizedBox(height: 16),
            _buildDataNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports at a glance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor cold-chain performance and operational activity.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FRONTEND DEMO · SAMPLE DATA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.query_stats_rounded, size: 54, color: Colors.white),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _metricCard(
    String label,
    String value,
    String detail,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: .65)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: color.withValues(alpha: .65),
                size: 17,
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceChart() {
    const values = [94.0, 97.0, 95.0, 98.0, 96.0, 97.0, 96.0];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      height: 230,
      padding: const EdgeInsets.fromLTRB(10, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: .65)),
      ),
      child: BarChart(
        BarChartData(
          minY: 85,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: .65),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: 5,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      days[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  fromY: 85,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }

  Widget _buildReportControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: .7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report category',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedReport,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _reportTypes
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() {
              _selectedReport = value ?? _reportTypes.first;
              _reportGenerated = false;
            }),
          ),
          const SizedBox(height: 14),
          const Text(
            'Report period',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _chooseDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _periodLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          if (_dateRange != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _dateRange = null;
                  _reportGenerated = false;
                }),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear date range'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportPreview() {
    final List<(String, String)> details;
    switch (_selectedReport) {
      case 'Cold-chain compliance':
        details = [
          ('Illustrative compliance rate', '96%'),
          ('Safe storage range', '2°C–8°C'),
          ('Active alerts', '$_activeAlerts'),
          ('Critical alerts', '$_criticalAlerts'),
        ];
        break;
      case 'Alerts summary':
        details = [
          ('Total alert records', '${alertList.length}'),
          ('Active alerts', '$_activeAlerts'),
          ('Critical active alerts', '$_criticalAlerts'),
          (
            'Resolved alerts',
            '${alertList.where((item) => item.status == AlertStatus.resolved).length}',
          ),
        ];
        break;
      case 'Vaccine batches & expiry':
        details = [
          ('Total batches', '${batchList.length}'),
          ('Active batches', '$_activeBatches'),
          ('Total doses listed', '$_totalDoses'),
          (
            'Marked expired',
            '${batchList.where((item) => item.status == BatchStatus.expired).length}',
          ),
        ];
        break;
      default:
        details = [
          ('Total maintenance records', '${maintenanceList.length}'),
          ('Open records', '$_openMaintenance'),
          ('Completed records', '$_completedMaintenance'),
          (
            'High/critical priority',
            '${maintenanceList.where((item) => item.priority == MaintenancePriority.high || item.priority == MaintenancePriority.critical).length}',
          ),
        ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedReport,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Period: $_periodLabel',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 24),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      detail.$1,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    detail.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _exportCsv,
              icon: const Icon(Icons.copy_all_rounded),
              label: const Text('Copy report as CSV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0A3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF946200), size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Frontend stage: these reports use the app’s local sample records. The compliance trend and 96% figure are illustrative. Date selection labels the report period but does not yet filter the sample records. Firebase, real sensor history, PDF export and file downloads are not connected.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF725000),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
