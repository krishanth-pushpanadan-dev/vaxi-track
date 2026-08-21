import 'user_model.dart';

class RolePermissions {
  // ============================================================
  // DASHBOARD
  // ============================================================

  /// All authenticated users can access the dashboard.
  static bool canAccessDashboard(UserRole role) {
    return true;
  }

  // ============================================================
  // DEVICES
  // ============================================================

  /// Admin, Warehouse Staff and Pharmacist can view IoT devices.
  ///
  /// Pharmacists may have IoT devices inside pharmacies
  /// or vaccine storage rooms.
  static bool canViewDevices(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can add devices.
  static bool canAddDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can edit devices.
  static bool canEditDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can delete devices.
  static bool canDeleteDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // VACCINE BATCHES
  // ============================================================

  /// All roles can view vaccine batches.
  static bool canViewBatches(UserRole role) {
    return true;
  }

  /// Admin, Warehouse Staff and Sales Representatives
  /// can add vaccine batches.
  static bool canAddBatch(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// Admin, Warehouse Staff and Sales Representatives
  /// can edit vaccine batches.
  static bool canEditBatch(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// Admin, Warehouse Staff and Pharmacist can delete vaccine batches.
  static bool canDeleteBatch(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // QR CODE
  // ============================================================

  /// Admin, Warehouse Staff and Sales Representatives
  /// can generate vaccine QR codes.
  static bool canGenerateQR(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// All roles can scan vaccine QR codes.
  static bool canScanQR(UserRole role) {
    return true;
  }

  // ============================================================
  // ALERTS
  // ============================================================

  /// All roles can view alerts.
  static bool canViewAlerts(UserRole role) {
    return true;
  }

  /// Only Admin and Warehouse Staff can manage alerts.
  static bool canManageAlerts(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  /// Admin, Warehouse Staff, Sales Representative and
  /// Pharmacist can view vaccine inventory.
  static bool canViewInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can add stock.
  static bool canAddInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can edit inventory.
  static bool canEditInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can remove/reduce stock.
  static bool canRemoveInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // ORDER REQUESTS
  // ============================================================

  /// Admin, Warehouse Staff, Sales Representative and
  /// Pharmacist can view order requests.
  static bool canViewOrderRequests(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff, Sales Representative and
  /// Pharmacist can create order requests.
  static bool canCreateOrderRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff and Pharmacist can manage
  /// order requests.
  static bool canManageOrderRequests(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Users can cancel their own order requests.
  static bool canCancelOrderRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Admin and Warehouse Staff can update order status.
  ///
  /// Example:
  /// Pending → Approved → Dispatched → Delivered
  static bool canUpdateOrderStatus(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  /// Admin, Warehouse Staff, Sales Representative and
  /// Pharmacist can track orders.
  static bool canTrackOrders(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // WASTE MANAGEMENT
  // ============================================================

  /// Admin, Warehouse Staff, Facility Staff and Pharmacist
  /// can view waste records.
  static bool canViewWaste(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin, Warehouse Staff, Facility Staff and Pharmacist
  /// can register vaccine wastage.
  static bool canRegisterWaste(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff ||
        role == UserRole.pharmacist;
  }

  /// Only Admin can approve wastage records.
  static bool canApproveWaste(UserRole role) {
    return role == UserRole.admin;
  }

  // ============================================================
  // MAINTENANCE
  // ============================================================

  /// Admin, Warehouse Staff and Facility Staff
  /// can view maintenance.
  static bool canViewMaintenance(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff;
  }

  /// Admin, Warehouse Staff and Facility Staff
  /// can create maintenance requests.
  static bool canCreateMaintenanceRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff;
  }

  /// Admin and Warehouse Staff can manage maintenance.
  static bool canManageMaintenance(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  // ============================================================
  // USER MANAGEMENT
  // ============================================================

  /// Only Admin can manage system users.
  static bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  // ============================================================
  // REPORTS
  // ============================================================

  /// Admin, Warehouse Staff and Sales Representatives
  /// can access reports.
  static bool canViewReports(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  /// All authenticated users can access their settings.
  static bool canAccessSettings(UserRole role) {
    return true;
  }
}
