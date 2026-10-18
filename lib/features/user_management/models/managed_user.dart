import '../../authentication/models/user_model.dart';

class ManagedUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  const ManagedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  ManagedUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) => ManagedUser(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
  );

  String get roleName => switch (role) {
    UserRole.admin => 'Admin',
    UserRole.warehouseStaff => 'Warehouse Staff',
    UserRole.salesRepresentative => 'Sales Representative',
    UserRole.facilityStaff => 'Facility Staff',
    UserRole.pharmacist => 'Pharmacist',
  };
}
