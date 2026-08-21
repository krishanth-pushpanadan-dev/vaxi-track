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

  /// All roles except Pharmacist can view IoT devices.
  static bool canViewDevices(UserRole role) {
    return role == UserRole.pharmacist;
  }

  /// Admin and Warehouse Staff can add devices.
  static bool canAddDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Admin and Warehouse Staff can edit devices.
  static bool canEditDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Only Admin can delete devices.
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

  /// Admin and Warehouse Staff can delete vaccine batches.
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

  /// Users who can view vaccine inventory.
  ///
  /// Pharmacist needs inventory access because inventory
  /// is important for deciding when to request vaccines.
  static bool canViewInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Only Admin and Warehouse Staff can add stock.
  static bool canAddInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Only Admin and Warehouse Staff can edit inventory.
  static bool canEditInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  /// Only Admin and Warehouse Staff can remove/reduce stock.
  static bool canRemoveInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // ORDER REQUESTS
  // ============================================================

  /// Users who can view order requests.
  static bool canViewOrderRequests(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Users who can create order requests.
  ///
  /// Pharmacists can create requests when stock is low.
  static bool canCreateOrderRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  /// Admin and Warehouse Staff can approve/reject
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

  /// Users who can track order requests.
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
  ///
  /// Sales Representative does not need direct waste
  /// management access.
  static bool canViewWaste(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff ||
        role == UserRole.pharmacist;
  }

  /// Users who can register vaccine wastage.
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

  /// Users who can create maintenance requests.
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
