enum WasteReason { expired, damaged, temperatureExcursion, contaminated, other }

enum WasteStatus { pending, approved, rejected }

class WasteItem {
  final String id;
  final String medicineName;
  final String batchNumber;
  final int quantity;
  final String unit;
  final WasteReason reason;
  final WasteStatus status;
  final String reportedBy;
  final String reportedByRole;
  final String description;
  final String imagePath;
  final DateTime reportedDate;
  final DateTime? expiryDate;
  final String location;
  final bool requiresReview;

  const WasteItem({
    required this.id,
    required this.medicineName,
    required this.batchNumber,
    required this.quantity,
    required this.unit,
    required this.reason,
    required this.status,
    required this.reportedBy,
    required this.reportedByRole,
    required this.description,
    required this.imagePath,
    required this.reportedDate,
    this.expiryDate,
    required this.location,
    required this.requiresReview,
  });

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String get reasonLabel {
    switch (reason) {
      case WasteReason.expired:
        return "Expired";

      case WasteReason.damaged:
        return "Damaged";

      case WasteReason.temperatureExcursion:
        return "Temperature Excursion";

      case WasteReason.contaminated:
        return "Contaminated";

      case WasteReason.other:
        return "Other";
    }
  }

  String get statusLabel {
    switch (status) {
      case WasteStatus.pending:
        return "Pending";

      case WasteStatus.approved:
        return "Approved";

      case WasteStatus.rejected:
        return "Rejected";
    }
  }

  // ============================================================
  // EXPIRY CHECK
  // ============================================================

  bool get isExpired {
    if (expiryDate == null) {
      return false;
    }

    return expiryDate!.isBefore(DateTime.now());
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  WasteItem copyWith({
    String? id,
    String? medicineName,
    String? batchNumber,
    int? quantity,
    String? unit,
    WasteReason? reason,
    WasteStatus? status,
    String? reportedBy,
    String? reportedByRole,
    String? description,
    String? imagePath,
    DateTime? reportedDate,
    DateTime? expiryDate,
    String? location,
    bool? requiresReview,
  }) {
    return WasteItem(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByRole: reportedByRole ?? this.reportedByRole,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      reportedDate: reportedDate ?? this.reportedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      location: location ?? this.location,
      requiresReview: requiresReview ?? this.requiresReview,
    );
  }
}
