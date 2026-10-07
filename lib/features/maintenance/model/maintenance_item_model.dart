enum MaintenanceType {
  preventive,
  corrective,
  calibration,
  inspection,
  emergency,
}

enum MaintenancePriority { low, medium, high, critical }

enum MaintenanceStatus { scheduled, pending, inProgress, completed, cancelled }

class MaintenanceItem {
  final String id;
  final String deviceId;
  final String deviceName;
  final String location;
  final MaintenanceType type;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final String issueTitle;
  final String description;
  final String reportedBy;
  final String reportedByRole;
  final String? assignedTo;
  final DateTime reportedDate;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? technicianNotes;
  final double? maintenanceCost;
  final bool requiresReview;

  const MaintenanceItem({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.location,
    required this.type,
    required this.priority,
    required this.status,
    required this.issueTitle,
    required this.description,
    required this.reportedBy,
    required this.reportedByRole,
    this.assignedTo,
    required this.reportedDate,
    this.scheduledDate,
    this.completedDate,
    this.technicianNotes,
    this.maintenanceCost,
    required this.requiresReview,
  });

  // Display helpers

  String get typeLabel {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventive Maintenance';
      case MaintenanceType.corrective:
        return 'Corrective Maintenance';
      case MaintenanceType.calibration:
        return 'Calibration';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.emergency:
        return 'Emergency Maintenance';
    }
  }

  String get priorityLabel {
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

  String get statusLabel {
    switch (status) {
      case MaintenanceStatus.scheduled:
        return 'Scheduled';
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isCompleted => status == MaintenanceStatus.completed;

  bool get isOverdue {
    if (scheduledDate == null || isCompleted) {
      return false;
    }

    return scheduledDate!.isBefore(DateTime.now()) &&
        status != MaintenanceStatus.cancelled;
  }

  bool get isCritical => priority == MaintenancePriority.critical;

  MaintenanceItem copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? location,
    MaintenanceType? type,
    MaintenancePriority? priority,
    MaintenanceStatus? status,
    String? issueTitle,
    String? description,
    String? reportedBy,
    String? reportedByRole,
    String? assignedTo,
    DateTime? reportedDate,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? technicianNotes,
    double? maintenanceCost,
    bool? requiresReview,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      location: location ?? this.location,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      issueTitle: issueTitle ?? this.issueTitle,
      description: description ?? this.description,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByRole: reportedByRole ?? this.reportedByRole,
      assignedTo: assignedTo ?? this.assignedTo,
      reportedDate: reportedDate ?? this.reportedDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      technicianNotes: technicianNotes ?? this.technicianNotes,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      requiresReview: requiresReview ?? this.requiresReview,
    );
  }
}
