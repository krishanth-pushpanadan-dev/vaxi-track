import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../core/dummy/dummy_devices.dart';
import '../../alerts/data/alert_dummy_data.dart';
import '../../alerts/models/alert_model.dart';
import '../../authentication/models/role_permissions.dart';
import '../../authentication/services/auth_service.dart';
import '../../maintenance/data/maintenance_dummy_data.dart';
import '../../maintenance/model/maintenance_item_model.dart';
import '../../vaccine_batches/data/batch_dummy_data.dart';
import '../../waste_management/model/waste_item_model.dart';
import '../services/report_data_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ReportDataService _reportService = ReportDataService.instance;

  static const List<_ReportOption> _options = [
    _ReportOption('overview', 'Operations overview', Icons.dashboard_outlined),
    _ReportOption('devices', 'Device status', Icons.sensors_outlined),
    _ReportOption(
      'temperature',
      'Temperature & cold chain',
      Icons.thermostat_outlined,
    ),
    _ReportOption(
      'alerts',
      'Alerts & incidents',
      Icons.notifications_active_outlined,
    ),
    _ReportOption(
      'batches',
      'Vaccine batches & expiry',
      Icons.inventory_2_outlined,
    ),
    _ReportOption('inventory', 'Inventory & stock', Icons.warehouse_outlined),
    _ReportOption('maintenance', 'Maintenance activity', Icons.build_outlined),
    _ReportOption('waste', 'Waste & disposal', Icons.delete_outline_rounded),
  ];

  String _selectedReport = 'overview';
  DateTimeRange? _dateRange;
  bool _hasGenerated = false;
  String _search = '';

  ReportDataset get _dataset => _reportService.build(
    _selectedReport,
    range: _dateRange == null
        ? null
        : DateTimeRangeLike(_dateRange!.start, _dateRange!.end),
  );

  List<ReportRow> get _filteredRows => _dataset.filter(
    _dateRange == null
        ? null
        : DateTimeRangeLike(_dateRange!.start, _dateRange!.end),
    _search,
  );

  int get _activeAlerts =>
      alertList.where((a) => a.status == AlertStatus.active).length;
  int get _criticalAlerts => alertList
      .where(
        (a) =>
            a.status == AlertStatus.active &&
            a.severity == AlertSeverity.critical,
      )
      .length;
  int get _onlineDevices => deviceList.where((d) => d.isOnline).length;
  int get _attentionDevices =>
      deviceList.where((d) => !d.isOnline || d.hasWarning).length;
  int get _openMaintenance => maintenanceList
      .where(
        (m) =>
            m.status != MaintenanceStatus.completed &&
            m.status != MaintenanceStatus.cancelled,
      )
      .length;
  int get _pendingWaste => _reportService.wasteItems
      .where((w) => w.status == WasteStatus.pending)
      .length;
  int get _totalDoses =>
      batchList.fold<int>(0, (sum, item) => sum + item.quantity);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chooseDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 3),
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month, now.day),
          ),
      helpText: 'Filter report records by date',
    );
    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
        _hasGenerated = false;
      });
    }
  }

  void _generateReport() {
    setState(() => _hasGenerated = true);
    final message = _dataset.dateFilterApplied && _dateRange != null
        ? 'Report generated with the selected date range.'
        : 'Report generated from current sample records.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _copyCsv() async {
    final dataset = _dataset;
    final rows = _filteredRows;
    final csv = _reportService.toCsv(dataset, rows, search: _search);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CSV copied: ${rows.length} data rows. Paste into Excel or another spreadsheet.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveCsv() async {
    final dataset = _dataset;
    final rows = _filteredRows;
    final csv = _reportService.toCsv(dataset, rows, search: _search);
    try {
      await FileSaver.instance.saveFile(
        name:
            'vaxitrack_${_selectedReport}_${DateTime.now().millisecondsSinceEpoch}',
        bytes: Uint8List.fromList(utf8.encode(csv)),
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV export prepared with ${rows.length} records.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save CSV: $error. Use Copy CSV as an alternative.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportPdf() async {
    final dataset = _dataset;
    final rows = _filteredRows;
    final document = pw.Document();
    final tableRows = rows
        .map((row) => row.values.map((value) => value).toList())
        .toList();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'VaxiTrack Sri Lanka',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            dataset.title,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text('Period: ${dataset.periodLabel}'),
          pw.Text('Generated: ${DateTime.now().toLocal()}'),
          pw.SizedBox(height: 8),
          pw.Text(dataset.description),
          pw.SizedBox(height: 14),
          pw.Text(
            'Records: ${rows.length}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (rows.isEmpty)
            pw.Text('No records match the selected filters.')
          else
            pw.TableHelper.fromTextArray(
              headers: dataset.columns,
              data: tableRows,
              headerStyle: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 7),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 5,
              ),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: .4),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
            ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Source: local sample records in the VaxiTrack frontend. This document is not a live Firebase or sensor-history report.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => document.save(),
        name: 'vaxitrack_${_selectedReport}_report.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not prepare PDF: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copySummary() async {
    final dataset = _dataset;
    final rows = _filteredRows;
    final summary = StringBuffer()
      ..writeln('VaxiTrack Sri Lanka')
      ..writeln(dataset.title)
      ..writeln('Period: ${dataset.periodLabel}')
      ..writeln('Records: ${rows.length}')
      ..writeln('Generated: ${DateTime.now()}');
    for (final row in rows.take(12)) {
      summary.writeln(row.values.join(' | '));
    }
    await Clipboard.setData(ClipboardData(text: summary.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report summary copied to clipboard.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _rangeLabel {
    if (_dateRange == null) return 'All available records';
    return '${_formatDate(_dateRange!.start)} – ${_formatDate(_dateRange!.end)}';
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';
  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
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
            tooltip: 'Refresh data',
            onPressed: () => setState(() => _hasGenerated = false),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _buildHero(),
            const SizedBox(height: 18),
            _sectionHeading(
              'Operational overview',
              'Calculated from current sample records',
            ),
            const SizedBox(height: 12),
            _buildMetricGrid(),
            const SizedBox(height: 22),
            _sectionHeading(
              'Current device readings',
              'Latest values in the local device sample',
            ),
            const SizedBox(height: 12),
            _buildTemperatureChart(),
            const SizedBox(height: 22),
            _sectionHeading(
              'Build a report',
              'Select a module, filter the records and generate a detailed report',
            ),
            const SizedBox(height: 12),
            _buildControls(),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Generate report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_hasGenerated) ...[
              const SizedBox(height: 18),
              _buildGeneratedReport(),
            ],
            const SizedBox(height: 18),
            _buildDataNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
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
                  'Reports & Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Review device health, cold-chain alerts, vaccine stock, maintenance and waste records in one place.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .9),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LOCAL SAMPLE RECORDS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.query_stats_rounded, size: 52, color: Colors.white),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) => Column(
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
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    ],
  );

  Widget _buildMetricGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _metricCard(
          'Devices online',
          '$_onlineDevices/${deviceList.length}',
          '$_attentionDevices need attention',
          Icons.sensors_rounded,
          AppColors.primary,
        ),
        _metricCard(
          'Active alerts',
          '$_activeAlerts',
          '$_criticalAlerts critical',
          Icons.notifications_active_rounded,
          AppColors.danger,
        ),
        _metricCard(
          'Vaccine doses listed',
          _totalDoses.toString(),
          '${batchList.length} batch records',
          Icons.inventory_2_rounded,
          const Color(0xFF198754),
        ),
        _metricCard(
          'Open maintenance',
          '$_openMaintenance',
          '$_pendingWaste waste reports pending',
          Icons.build_circle_rounded,
          const Color(0xFF8B5CF6),
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
        border: Border.all(color: AppColors.border.withValues(alpha: .75)),
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
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
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

  Widget _buildTemperatureChart() {
    final devices = deviceList;
    final minValue = devices
        .map((d) => d.temperature)
        .reduce((a, b) => a < b ? a : b);
    final maxValue = devices
        .map((d) => d.temperature)
        .reduce((a, b) => a > b ? a : b);
    final lower = minValue < 0 ? minValue - 5 : 0.0;
    final upper = maxValue + 3;
    final interval = ((upper - lower) / 4).clamp(1.0, 10.0).toDouble();
    return Container(
      height: 245,
      padding: const EdgeInsets.fromLTRB(8, 18, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: .75)),
      ),
      child: BarChart(
        BarChartData(
          minY: lower,
          maxY: upper,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: .7),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    '${devices[group.x].name}\n${rod.toY.toStringAsFixed(1)} °C',
                    const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
            ),
          ),
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
                reservedSize: 38,
                interval: interval,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
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
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= devices.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      devices[index].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            devices.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: devices[index].temperature,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                  color: !devices[index].isOnline || devices[index].hasWarning
                      ? AppColors.danger
                      : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: .75)),
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
            items: _options
                .map(
                  (option) => DropdownMenuItem(
                    value: option.id,
                    child: Row(
                      children: [
                        Icon(option.icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() {
              _selectedReport = value ?? 'overview';
              _hasGenerated = false;
            }),
          ),
          const SizedBox(height: 14),
          const Text(
            'Date range',
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
                      _rangeLabel,
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
                  _hasGenerated = false;
                }),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear date range'),
              ),
            ),
          if (!_dataset.dateFilterApplied)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'This report is a current snapshot; a historical date filter is not applicable.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneratedReport() {
    final dataset = _dataset;
    final rows = _filteredRows;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dataset.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataset.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoPill(Icons.calendar_today_outlined, dataset.periodLabel),
              _infoPill(Icons.table_rows_outlined, '${rows.length} records'),
              if (_search.trim().isNotEmpty)
                _infoPill(Icons.search, 'Filtered: ${_search.trim()}'),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _search = value),
            decoration: InputDecoration(
              hintText: 'Search within report records',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _search = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 34,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text('No records match these filters.'),
                  ],
                ),
              ),
            ),
          if (rows.isNotEmpty) _buildDataTable(dataset.columns, rows),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _saveCsv,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Save CSV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _copyCsv,
                icon: const Icon(Icons.table_view_rounded),
                label: const Text('Copy CSV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _copySummary,
                icon: const Icon(Icons.copy_all_rounded),
                label: const Text('Copy summary'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<String> columns, List<ReportRow> rows) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 440),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              dataRowMinHeight: 44,
              dataRowMaxHeight: 68,
              columnSpacing: 22,
              columns: columns
                  .map(
                    (c) => DataColumn(
                      label: Text(
                        c,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: row.values
                          .map(
                            (value) => DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 190,
                                ),
                                child: Text(
                                  value,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _buildDataNote() {
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
              'Reports are calculated from the app’s current local sample records. The temperature chart is a current snapshot, not historical telemetry. Alert timestamps are approximate because the sample alert model stores labels such as “2 min ago”. Data changes are held in memory until the app is restarted. Firebase and historical sensor telemetry are not connected yet. CSV and PDF exports are available for the sample records.',
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

class _ReportOption {
  final String id;
  final String label;
  final IconData icon;
  const _ReportOption(this.id, this.label, this.icon);
}
