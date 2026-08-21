enum UserRole {
  admin,
  warehouseStaff,
  salesRepresentative,
  facilityStaff,
  pharmacist,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  String get roleName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';

      case UserRole.warehouseStaff:
        return 'Warehouse Staff';

      case UserRole.salesRepresentative:
        return 'Sales Representative';

      case UserRole.facilityStaff:
        return 'Facility Staff';

      case UserRole.pharmacist:
        return 'Pharmacist';
    }
  }
}
