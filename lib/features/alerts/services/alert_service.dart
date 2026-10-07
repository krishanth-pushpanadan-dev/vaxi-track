import 'package:vaxi_track/features/alerts/data/alert_dummy_data.dart';
import 'package:vaxi_track/features/alerts/models/alert_model.dart';
import 'package:vaxi_track/features/waste_management/model/waste_item_model.dart';

class AlertService {
  AlertService._();

  // ============================================================
  // CREATE ALERT FROM WASTE REPORT
  // ============================================================

  static void createWasteAlert(WasteItem wasteItem) {
    final alert = AlertModel(
      id: "WASTE-${wasteItem.id}",
      title: _getTitle(wasteItem.reason),
      description: _getDescription(wasteItem),
      deviceName: "Waste Management",
      location: wasteItem.location,
      time: _formatTime(wasteItem.reportedDate),
      temperature: 0.0,
      severity: _getSeverity(wasteItem.reason),
      status: AlertStatus.active,
      acknowledged: false,
    );

    alertList.insert(0, alert);
  }

  // ============================================================
  // ALERT TITLE
  // ============================================================

  static String _getTitle(WasteReason reason) {
    switch (reason) {
      case WasteReason.expired:
        return "Expired Medicine Reported";

      case WasteReason.damaged:
        return "Damaged Medicine Reported";

      case WasteReason.temperatureExcursion:
        return "Temperature Excursion Reported";

      case WasteReason.contaminated:
        return "Contaminated Medicine Reported";

      case WasteReason.other:
        return "Medicine Waste Reported";
    }
  }

  // ============================================================
  // ALERT DESCRIPTION
  // ============================================================

  static String _getDescription(WasteItem wasteItem) {
    return "${wasteItem.medicineName} "
        "(${wasteItem.batchNumber}) - "
        "${wasteItem.quantity} ${wasteItem.unit} "
        "reported as ${wasteItem.reasonLabel.toLowerCase()}.";
  }

  // ============================================================
  // ALERT SEVERITY
  // ============================================================

  static AlertSeverity _getSeverity(WasteReason reason) {
    switch (reason) {
      case WasteReason.expired:
        return AlertSeverity.warning;

      case WasteReason.damaged:
        return AlertSeverity.warning;

      case WasteReason.temperatureExcursion:
        return AlertSeverity.critical;

      case WasteReason.contaminated:
        return AlertSeverity.critical;

      case WasteReason.other:
        return AlertSeverity.info;
    }
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, "0");
    final minute = dateTime.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }
}
