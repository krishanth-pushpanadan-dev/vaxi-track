import 'package:intl/intl.dart';

import '../../../core/dummy/dummy_devices.dart';
import '../../alerts/data/alert_dummy_data.dart';
import '../../alerts/models/alert_model.dart';
import '../../inventory/model/inventory_item_model.dart';
import '../../inventory/data/inventory_dummy_data.dart';
import '../../maintenance/data/maintenance_dummy_data.dart';
import '../../maintenance/model/maintenance_item_model.dart';
import '../../vaccine_batches/data/batch_dummy_data.dart';
import '../../vaccine_batches/models/batch_model.dart';
import '../../waste_management/model/waste_item_model.dart';
import '../../waste_management/data/waste_dummy_data.dart';

/// Report rows are created from the app's existing in-memory sample records.
/// The service is intentionally separated from the UI so Firebase can replace
/// these sources later without rebuilding the Reports screen.
class ReportRow {
  final DateTime? date;
  final List<String> values;

  const ReportRow({required this.values, this.date});
}

class ReportDataset {
  final String title;
  final String description;
  final List<String> columns;
  final List<ReportRow> rows;
  final String periodLabel;
  final bool dateFilterApplied;

  const ReportDataset({
    required this.title,
    required this.description,
    required this.columns,
    required this.rows,
    required this.periodLabel,
    required this.dateFilterApplied,
  });

  List<ReportRow> filter(DateTimeRangeLike? range, String query) {
    final q = query.trim().toLowerCase();
    return rows.where((row) {
      if (range != null && dateFilterApplied) {
        final date = row.date;
        if (date == null) return false;
        final start = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );
        final end = DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
          23,
          59,
          59,
        );
        if (date.isBefore(start) || date.isAfter(end)) return false;
      }
      return q.isEmpty ||
          row.values.any((value) => value.toLowerCase().contains(q));
    }).toList();
  }
}

/// Minimal date-range interface keeps the data service independent of widgets.
class DateTimeRangeLike {
  final DateTime start;
  final DateTime end;
  const DateTimeRangeLike(this.start, this.end);
}

class ReportDataService {
  ReportDataService._();
  static final ReportDataService instance = ReportDataService._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static String _fmt(DateTime? value) =>
      value == null ? '—' : _date.format(value);
  List<InventoryItem> get inventoryItems => inventoryDummyItems;
  List<WasteItem> get wasteItems => wasteDummyItems;

  ReportDataset build(String reportId, {DateTimeRangeLike? range}) {
    final period = range == null
        ? 'All available sample records'
        : '${_fmt(range.start)} – ${_fmt(range.end)}';
    switch (reportId) {
      case 'devices':
        return ReportDataset(
          title: 'Device Status Report',
          description:
              'Current device connectivity, sensor readings and battery/network status.',
          columns: const [
            'Device ID',
            'Device',
            'Location',
            'Temperature °C',
            'Humidity %',
            'Battery %',
            'Signal %',
            'Status',
            'Last sync',
          ],
          rows: deviceList
              .map(
                (d) => ReportRow(
                  values: [
                    d.id,
                    d.name,
                    d.location,
                    d.temperature.toStringAsFixed(1),
                    d.humidity.toStringAsFixed(0),
                    '${d.battery}',
                    '${d.signal}',
                    !d.isOnline
                        ? 'Offline'
                        : d.hasWarning
                        ? 'Warning'
                        : 'Online',
                    d.lastSync,
                  ],
                ),
              )
              .toList(),
          periodLabel: 'Current snapshot',
          dateFilterApplied: false,
        );
      case 'temperature':
        final rows = deviceList
            .map(
              (d) => ReportRow(
                values: [
                  d.id,
                  d.name,
                  d.location,
                  '${d.temperature.toStringAsFixed(1)} °C',
                  !d.isOnline
                      ? 'Offline'
                      : d.hasWarning
                      ? 'Needs attention'
                      : 'No warning flagged',
                  d.lastSync,
                ],
              ),
            )
            .toList();
        return ReportDataset(
          title: 'Temperature & Cold-chain Report',
          description:
              'Current sample sensor readings and device warning states. This is not historical sensor telemetry.',
          columns: const [
            'Device ID',
            'Device',
            'Location',
            'Current temperature',
            'Current assessment',
            'Last sync',
          ],
          rows: rows,
          periodLabel: 'Current snapshot',
          dateFilterApplied: false,
        );
      case 'alerts':
        return ReportDataset(
          title: 'Alerts & Incidents Report',
          description:
              'Alert register with severity, acknowledgement and current resolution state.',
          columns: const [
            'Alert ID',
            'Title',
            'Device',
            'Location',
            'Temperature °C',
            'Severity',
            'Status',
            'Acknowledged',
            'Approx. date',
          ],
          rows: alertList
              .map(
                (a) => ReportRow(
                  date: _alertDate(a.time),
                  values: [
                    a.id,
                    a.title,
                    a.deviceName,
                    a.location,
                    a.temperature.toStringAsFixed(1),
                    a.severityText,
                    a.statusText,
                    a.acknowledged ? 'Yes' : 'No',
                    _fmt(_alertDate(a.time)),
                  ],
                ),
              )
              .toList(),
          periodLabel: period,
          dateFilterApplied: true,
        );
      case 'batches':
        return ReportDataset(
          title: 'Vaccine Batches & Expiry Report',
          description:
              'Batch quantities, assigned storage, current reading and expiry dates.',
          columns: const [
            'Batch ID',
            'Vaccine',
            'Batch number',
            'Manufacturer',
            'Quantity',
            'Location',
            'Assigned device',
            'Expiry date',
            'Status',
          ],
          rows: batchList.map((b) {
            final expiry = _parseBatchDate(b.expiryDate);
            return ReportRow(
              date: expiry,
              values: [
                b.id,
                b.vaccineName,
                b.batchNumber,
                b.manufacturer,
                '${b.quantity}',
                b.location,
                b.assignedDevice,
                b.expiryDate,
                b.statusText,
              ],
            );
          }).toList(),
          periodLabel: period,
          dateFilterApplied: true,
        );
      case 'inventory':
        return ReportDataset(
          title: 'Inventory & Stock Report',
          description:
              'Current available stock, utilization, expiry and stock-risk indicators.',
          columns: const [
            'Inventory ID',
            'Medicine',
            'Batch number',
            'Total doses',
            'Available doses',
            'Used doses',
            'Stock %',
            'Location',
            'Expiry date',
            'Stock status',
          ],
          rows: inventoryItems
              .map(
                (i) => ReportRow(
                  date: i.expiryDate,
                  values: [
                    i.id,
                    i.vaccineName,
                    i.batchNumber,
                    '${i.totalDoses}',
                    '${i.availableDoses}',
                    '${i.usedDoses}',
                    '${(i.stockPercentage * 100).round()}%',
                    i.storageLocation,
                    _fmt(i.expiryDate),
                    i.isExpired
                        ? 'Expired'
                        : i.isOutOfStock
                        ? 'Out of stock'
                        : i.isLowStock
                        ? 'Low stock'
                        : i.isExpiringSoon
                        ? 'Expiring soon'
                        : 'Available',
                  ],
                ),
              )
              .toList(),
          periodLabel: period,
          dateFilterApplied: true,
        );
      case 'maintenance':
        return ReportDataset(
          title: 'Maintenance Activity Report',
          description:
              'Maintenance work orders, approval, ownership, priority and cost.',
          columns: const [
            'Maintenance ID',
            'Issue',
            'Device',
            'Location',
            'Type',
            'Priority',
            'Status',
            'Approval',
            'Reported by',
            'Assigned to',
            'Reported date',
            'Scheduled date',
            'Completed date',
            'Cost',
          ],
          rows: maintenanceList
              .map(
                (m) => ReportRow(
                  date: m.reportedDate,
                  values: [
                    m.id,
                    m.issueTitle,
                    m.deviceName,
                    m.location,
                    m.typeLabel,
                    m.priorityLabel,
                    m.statusLabel,
                    m.approvalStatusLabel,
                    m.reportedBy,
                    m.assignedTo ?? 'Unassigned',
                    _fmt(m.reportedDate),
                    _fmt(m.scheduledDate),
                    _fmt(m.completedDate),
                    m.maintenanceCost == null
                        ? 'Not recorded'
                        : m.maintenanceCost!.toStringAsFixed(2),
                  ],
                ),
              )
              .toList(),
          periodLabel: period,
          dateFilterApplied: true,
        );
      case 'waste':
        return ReportDataset(
          title: 'Waste & Disposal Report',
          description:
              'Waste declarations with reason, quantity, approval status and reporting location.',
          columns: const [
            'Waste ID',
            'Medicine',
            'Batch number',
            'Quantity',
            'Unit',
            'Reason',
            'Status',
            'Reported by',
            'Location',
            'Expiry date',
            'Reported date',
          ],
          rows: wasteItems
              .map(
                (w) => ReportRow(
                  date: w.reportedDate,
                  values: [
                    w.id,
                    w.medicineName,
                    w.batchNumber,
                    '${w.quantity}',
                    w.unit,
                    w.reasonLabel,
                    w.statusLabel,
                    w.reportedBy,
                    w.location,
                    _fmt(w.expiryDate),
                    _fmt(w.reportedDate),
                  ],
                ),
              )
              .toList(),
          periodLabel: period,
          dateFilterApplied: true,
        );
      default:
        return ReportDataset(
          title: 'Operations Overview',
          description:
              'Summary of the currently available sample records across VaxiTrack modules.',
          columns: const ['Area', 'Metric', 'Value', 'Notes'],
          rows: _overviewRows(),
          periodLabel: 'Current snapshot',
          dateFilterApplied: false,
        );
    }
  }

  List<ReportRow> _overviewRows() {
    final online = deviceList.where((d) => d.isOnline).length;
    final warning = deviceList.where((d) => d.hasWarning).length;
    final activeAlerts = alertList
        .where((a) => a.status == AlertStatus.active)
        .length;
    final criticalAlerts = alertList
        .where(
          (a) =>
              a.status == AlertStatus.active &&
              a.severity == AlertSeverity.critical,
        )
        .length;
    final activeBatches = batchList
        .where((b) => b.status != BatchStatus.expired)
        .length;
    final doses = batchList.fold<int>(0, (sum, b) => sum + b.quantity);
    final openMaintenance = maintenanceList
        .where(
          (m) =>
              m.status != MaintenanceStatus.completed &&
              m.status != MaintenanceStatus.cancelled,
        )
        .length;
    final wastePending = wasteItems
        .where((w) => w.status == WasteStatus.pending)
        .length;
    return [
      ReportRow(
        values: [
          'Devices',
          'Total devices',
          '${deviceList.length}',
          'Current sample device list',
        ],
      ),
      ReportRow(
        values: [
          'Devices',
          'Online devices',
          '$online',
          'Current connectivity snapshot',
        ],
      ),
      ReportRow(
        values: [
          'Devices',
          'Devices flagged for attention',
          '$warning',
          'Warning flag from sample device records',
        ],
      ),
      ReportRow(
        values: [
          'Alerts',
          'Active alerts',
          '$activeAlerts',
          'Current alert status',
        ],
      ),
      ReportRow(
        values: [
          'Alerts',
          'Critical active alerts',
          '$criticalAlerts',
          'Current alert status',
        ],
      ),
      ReportRow(
        values: [
          'Batches',
          'Non-expired-status batches',
          '$activeBatches',
          'Uses the batch status field',
        ],
      ),
      ReportRow(
        values: [
          'Batches',
          'Total doses listed',
          '$doses',
          'Sum of sample batch quantities',
        ],
      ),
      ReportRow(
        values: [
          'Maintenance',
          'Open maintenance records',
          '$openMaintenance',
          'Excludes completed and cancelled',
        ],
      ),
      ReportRow(
        values: [
          'Waste',
          'Pending waste reports',
          '$wastePending',
          'Current sample waste register',
        ],
      ),
    ];
  }

  DateTime? _parseBatchDate(String value) {
    try {
      return DateFormat('dd MMM yyyy').parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  DateTime? _alertDate(String label) {
    final now = DateTime.now();
    final value = label.toLowerCase().trim();
    final match = RegExp(
      r'^(\d+)\s*(min|minutes|hour|hours)\s*ago$',
    ).firstMatch(value);
    if (match != null) {
      final amount = int.tryParse(match.group(1)!) ?? 0;
      return now.subtract(
        Duration(
          minutes: value.contains('min') ? amount : 0,
          hours: value.contains('hour') ? amount : 0,
        ),
      );
    }
    if (value == 'yesterday') return now.subtract(const Duration(days: 1));
    if (value == 'today') return now;
    return null;
  }

  String toCsv(ReportDataset dataset, List<ReportRow> rows, {String? search}) {
    final output = <List<String>>[
      ['VaxiTrack Sri Lanka'],
      ['Report', dataset.title],
      ['Description', dataset.description],
      ['Period', dataset.periodLabel],
      ['Generated at', DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())],
      if (search != null && search.isNotEmpty) ['Search filter', search],
      [],
      dataset.columns,
      ...rows.map((row) => row.values),
    ];
    return output.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return (escaped.contains(',') ||
            escaped.contains('"') ||
            escaped.contains('\n') ||
            escaped.contains('\r'))
        ? '"$escaped"'
        : escaped;
  }
}
