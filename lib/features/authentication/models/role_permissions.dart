import 'user_model.dart';

class RolePermissions {
  /// Check whether a role can access the Dashboard
  static bool canAccessDashboard(UserRole role) {
    return true;
  }

  /// Device permissions
  static bool canViewDevices(UserRole role) {
    return true;
  }

  static bool canAddDevice(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  static bool canEditDevice(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  static bool canDeleteDevice(UserRole role) {
    return role == UserRole.admin;
  }

  /// Vaccine Batch permissions
  static bool canViewBatches(UserRole role) {
    return true;
  }

  static bool canAddBatch(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  static bool canEditBatch(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  static bool canDeleteBatch(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  /// QR Code permissions
  static bool canGenerateQR(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  static bool canScanQR(UserRole role) {
    return true;
  }

  /// Alert permissions
  static bool canViewAlerts(UserRole role) {
    return true;
  }

  static bool canManageAlerts(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  /// Waste Management permissions
  static bool canViewWaste(UserRole role) {
    return true;
  }

  static bool canRegisterWaste(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff;
  }

  static bool canApproveWaste(UserRole role) {
    return role == UserRole.admin;
  }

  /// Maintenance permissions
  static bool canViewMaintenance(UserRole role) {
    return true;
  }

  static bool canCreateMaintenanceRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff;
  }

  static bool canManageMaintenance(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  /// User Management
  static bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  /// Reports
  static bool canViewReports(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// Settings
  static bool canAccessSettings(UserRole role) {
    return true;
  }
}
