import '../models/user_model.dart';

class RolePermissions {
  RolePermissions._();

  // ============================================================
  // DASHBOARD
  // ============================================================

  static bool canViewDashboard(UserRole role) {
    return true;
  }

  // ============================================================
  // DEVICES
  // ============================================================

  static bool canViewDevices(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.facilityStaff ||
        role == UserRole.pharmacist;
  }

  static bool canAddDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  static bool canEditDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  static bool canDeleteDevice(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // VACCINE BATCHES
  // ============================================================

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
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // QR CODE
  // ============================================================

  static bool canGenerateQR(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  static bool canScanQR(UserRole role) {
    return true;
  }

  // ============================================================
  // ALERTS
  // ============================================================

  static bool canViewAlerts(UserRole role) {
    return true;
  }

  static bool canManageAlerts(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  static bool canViewInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  static bool canAddInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  static bool canEditInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  static bool canRemoveInventory(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // ORDER REQUESTS
  // ============================================================

  static bool canViewOrderRequests(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  static bool canCreateOrderRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  static bool canManageOrderRequests(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.pharmacist;
  }

  static bool canCancelOrderRequest(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  static bool canUpdateOrderStatus(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  static bool canTrackOrder(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative ||
        role == UserRole.pharmacist;
  }

  // ============================================================
  // MARKETPLACE / PRODUCT SHOWCASE
  // ============================================================

  /// Allows users to view the products they manage/showcase.
  ///
  /// Admin:
  ///     Full access
  ///
  /// Warehouse Staff:
  ///     Can manage warehouse products
  ///
  /// Sales Representative:
  ///     Can showcase products they represent
  static bool canViewSupplierProducts(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// Allows a user to add a new product to the marketplace.
  static bool canAddProduct(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// Allows a user to edit an existing marketplace product.
  static bool canEditProduct(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  /// Allows a user to hide or show a product in the marketplace.
  static bool canManageProductVisibility(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  // ============================================================
  // WASTE MANAGEMENT
  // ============================================================

  static bool canViewWaste(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff ||
        role == UserRole.pharmacist;
  }

  static bool canRegisterWaste(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff ||
        role == UserRole.pharmacist;
  }

  static bool canApproveWaste(UserRole role) {
    return role == UserRole.admin;
  }

  // ============================================================
  // MAINTENANCE
  // ============================================================

  static bool canViewMaintenance(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff;
  }

  static bool canCreateMaintenance(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.facilityStaff;
  }

  static bool canManageMaintenance(UserRole role) {
    return role == UserRole.admin || role == UserRole.warehouseStaff;
  }

  // ============================================================
  // REPORTS
  // ============================================================

  static bool canViewReports(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.warehouseStaff ||
        role == UserRole.salesRepresentative;
  }

  // ============================================================
  // USER MANAGEMENT
  // ============================================================

  static bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewUsers(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canAddUser(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canEditUser(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canDeleteUser(UserRole role) {
    return role == UserRole.admin;
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  static bool canAccessSettings(UserRole role) {
    return true;
  }

  static bool canViewSettings(UserRole role) {
    return canAccessSettings(role);
  }
}
