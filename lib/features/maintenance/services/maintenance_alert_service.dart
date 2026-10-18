import '../../alerts/data/alert_dummy_data.dart';
import '../../alerts/models/alert_model.dart';
import '../model/maintenance_item_model.dart';

/// Creates and synchronizes in-memory alerts for maintenance issues.
///
/// Alerts are shared with the Alerts page through [alertList]. This service
/// does not persist data to Firebase yet.
class MaintenanceAlertService {
  MaintenanceAlertService._();

  static const String _idPrefix = 'MNT-ALERT-';

  /// Remembers the previous maintenance-trigger condition per item.
  ///
  /// This lets an alert reopen when an item transitions from not requiring an
  /// alert to requiring one again, while avoiding reopening an alert that a
  /// user manually resolved while the maintenance condition stayed unchanged.
  static final Map<String, bool> _lastShouldBeActive = <String, bool>{};

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
      final wasPreviouslyTriggering = _lastShouldBeActive[item.id];

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
        _lastShouldBeActive[item.id] = false;
        continue;
      }

      final refreshedAlert = _buildAlert(item);

      if (existingIndex == -1) {
        alertList.insert(0, refreshedAlert);
      } else {
        final existing = alertList[existingIndex];

        if (existing.status == AlertStatus.active) {
          // Refresh content without resetting acknowledgement or original time.
          alertList[existingIndex] = _copyAlert(
            refreshedAlert,
            time: existing.time,
            acknowledged: existing.acknowledged,
          );
        } else if (wasPreviouslyTriggering == false) {
          // Reopen only when the maintenance condition became active again.
          alertList[existingIndex] = _copyAlert(
            refreshedAlert,
            time: 'Updated just now',
            acknowledged: false,
            status: AlertStatus.active,
          );
        }
        // If the alert was resolved manually while the condition remained
        // active, keep it resolved rather than reopening it on every refresh.
      }

      _lastShouldBeActive[item.id] = true;
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
