enum MaintenanceType {
  preventive,
  corrective,
  calibration,
  inspection,
  emergency,
}

enum MaintenancePriority { low, medium, high, critical }

enum MaintenanceStatus { scheduled, pending, inProgress, completed, cancelled }

enum MaintenanceApprovalStatus { pending, approved, rejected }

class MaintenanceItem {
  final String id;
  final String deviceId;
  final String deviceName;
  final String location;

  final MaintenanceType type;
  final MaintenancePriority priority;
  final MaintenanceStatus status;

  final MaintenanceApprovalStatus approvalStatus;

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
    required this.approvalStatus,
    required this.issueTitle,
    required this.description,
    required this.reportedBy,
    required this.reportedByRole,
    required this.assignedTo,
    required this.reportedDate,
    required this.scheduledDate,
    required this.completedDate,
    required this.technicianNotes,
    required this.maintenanceCost,
    required this.requiresReview,
  });

  // ============================================================
  // TYPE LABEL
  // ============================================================

  String get typeLabel {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventive';

      case MaintenanceType.corrective:
        return 'Corrective';

      case MaintenanceType.calibration:
        return 'Calibration';

      case MaintenanceType.inspection:
        return 'Inspection';

      case MaintenanceType.emergency:
        return 'Emergency';
    }
  }

  // ============================================================
  // PRIORITY LABEL
  // ============================================================

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

  // ============================================================
  // STATUS LABEL
  // ============================================================

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

  // ============================================================
  // APPROVAL LABEL
  // ============================================================

  String get approvalStatusLabel {
    switch (approvalStatus) {
      case MaintenanceApprovalStatus.pending:
        return 'Pending Review';

      case MaintenanceApprovalStatus.approved:
        return 'Approved';

      case MaintenanceApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  // ============================================================
  // COMPLETED
  // ============================================================

  bool get isCompleted {
    return status == MaintenanceStatus.completed;
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  bool get isOverdue {
    if (scheduledDate == null || isCompleted) {
      return false;
    }

    return scheduledDate!.isBefore(DateTime.now()) &&
        status != MaintenanceStatus.cancelled;
  }

  // ============================================================
  // CRITICAL
  // ============================================================

  bool get isCritical {
    return priority == MaintenancePriority.critical;
  }

  // ============================================================
  // NEEDS APPROVAL
  // ============================================================

  bool get needsApproval {
    return approvalStatus == MaintenanceApprovalStatus.pending;
  }

  // ============================================================
  // APPROVED
  // ============================================================

  bool get isApproved {
    return approvalStatus == MaintenanceApprovalStatus.approved;
  }

  // ============================================================
  // REJECTED
  // ============================================================

  bool get isRejected {
    return approvalStatus == MaintenanceApprovalStatus.rejected;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  MaintenanceItem copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? location,
    MaintenanceType? type,
    MaintenancePriority? priority,
    MaintenanceStatus? status,
    MaintenanceApprovalStatus? approvalStatus,
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
      approvalStatus: approvalStatus ?? this.approvalStatus,
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
