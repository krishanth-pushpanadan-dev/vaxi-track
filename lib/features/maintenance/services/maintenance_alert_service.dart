import '../../alerts/data/alert_dummy_data.dart';
import '../../alerts/models/alert_model.dart';
import '../model/maintenance_item_model.dart';

/// Creates or updates in-memory alerts for maintenance issues.
///
/// This service uses the same [alertList] displayed by the Alerts page.
/// It does not persist alerts to Firebase yet.
class MaintenanceAlertService {
  MaintenanceAlertService._();

  static const String _idPrefix = 'MNT-ALERT-';

  /// Synchronizes maintenance alerts without creating duplicate alerts.
  ///
  /// Critical priority takes precedence over overdue status, so each
  /// maintenance request can produce at most one maintenance alert.
  static void syncMaintenanceAlerts(Iterable<MaintenanceItem> items) {
    for (final item in items) {
      final alertId = _alertIdFor(item.id);
      final existingIndex = alertList.indexWhere(
        (alert) => alert.id == alertId,
      );
      final shouldBeActive = _shouldHaveActiveAlert(item);

      if (!shouldBeActive) {
        if (existingIndex != -1) {
          final existing = alertList[existingIndex];
          if (existing.status != AlertStatus.resolved) {
            alertList[existingIndex] = _copyAlert(
              existing,
              status: AlertStatus.resolved,
              acknowledged: true,
              time: 'Updated just now',
            );
          }
        }
        continue;
      }

      final newAlert = _buildAlert(item);

      if (existingIndex == -1) {
        alertList.insert(0, newAlert);
      } else {
        // Keep a previously acknowledged/resolved alert as-is to avoid
        // repeatedly reopening the same issue every time the page is built.
        // Refresh the text only while the alert remains active.
        final existing = alertList[existingIndex];
        if (existing.status == AlertStatus.active) {
          alertList[existingIndex] = _copyAlert(
            newAlert,
            time: existing.time,
            acknowledged: existing.acknowledged,
          );
        }
      }
    }
  }

  static bool _shouldHaveActiveAlert(MaintenanceItem item) {
    if (item.status == MaintenanceStatus.completed ||
        item.status == MaintenanceStatus.cancelled) {
      return false;
    }

    return item.priority == MaintenancePriority.critical || item.isOverdue;
  }

  static String _alertIdFor(String maintenanceId) => '$_idPrefix$maintenanceId';

  static AlertModel _buildAlert(MaintenanceItem item) {
    final isCritical = item.priority == MaintenancePriority.critical;
    final title = isCritical
        ? 'Critical Maintenance Required'
        : 'Maintenance Overdue';
    final description = isCritical
        ? 'Critical-priority maintenance for ${item.deviceName} requires immediate attention. ${item.issueTitle}'
        : 'Maintenance for ${item.deviceName} is overdue. ${item.issueTitle}';

    return AlertModel(
      id: _alertIdFor(item.id),
      title: title,
      description: description,
      deviceName: item.deviceName,
      location: item.location,
      time: 'Just now',
      // Maintenance alerts do not represent a temperature measurement.
      // Zero is used because AlertModel currently requires a temperature.
      temperature: 0,
      severity: isCritical ? AlertSeverity.critical : AlertSeverity.warning,
      status: AlertStatus.active,
      acknowledged: false,
    );
  }

  static AlertModel _copyAlert(
    AlertModel alert, {
    AlertStatus? status,
    bool? acknowledged,
    String? time,
  }) {
    return AlertModel(
      id: alert.id,
      title: alert.title,
      description: alert.description,
      deviceName: alert.deviceName,
      location: alert.location,
      time: time ?? alert.time,
      temperature: alert.temperature,
      severity: alert.severity,
      status: status ?? alert.status,
      acknowledged: acknowledged ?? alert.acknowledged,
    );
  }
}
