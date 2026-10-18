import '../../authentication/models/user_model.dart';
import '../models/managed_user.dart';

/// In-memory sample data; replace this service with Firebase later.
class UserManagementService {
  UserManagementService._();
  static final UserManagementService instance = UserManagementService._();

  final List<ManagedUser> _users = [
    ManagedUser(
      id: 'USR-001',
      name: 'System Administrator',
      email: 'admin@vaxitrack.lk',
      role: UserRole.admin,
      isActive: true,
      createdAt: DateTime(2026, 1, 10),
    ),
    ManagedUser(
      id: 'USR-002',
      name: 'Nimal Perera',
      email: 'nimal.warehouse@vaxitrack.lk',
      role: UserRole.warehouseStaff,
      isActive: true,
      createdAt: DateTime(2026, 2, 12),
    ),
    ManagedUser(
      id: 'USR-003',
      name: 'Amaya Fernando',
      email: 'amaya.sales@vaxitrack.lk',
      role: UserRole.salesRepresentative,
      isActive: true,
      createdAt: DateTime(2026, 3, 5),
    ),
    ManagedUser(
      id: 'USR-004',
      name: 'Kasun Silva',
      email: 'kasun.facility@vaxitrack.lk',
      role: UserRole.facilityStaff,
      isActive: false,
      createdAt: DateTime(2026, 4, 18),
    ),
    ManagedUser(
      id: 'USR-005',
      name: 'Tharushi Jayawardena',
      email: 'tharushi.pharmacy@vaxitrack.lk',
      role: UserRole.pharmacist,
      isActive: true,
      createdAt: DateTime(2026, 5, 22),
    ),
  ];

  List<ManagedUser> get users => List.unmodifiable(_users);
  int get totalUsers => _users.length;
  int get activeUsers => _users.where((u) => u.isActive).length;
  int get inactiveUsers => _users.where((u) => !u.isActive).length;

  String? validateEmail(String email, {String? excludeUserId}) {
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized))
      return 'Enter a valid email address.';
    if (_users.any(
      (u) => u.email.toLowerCase() == normalized && u.id != excludeUserId,
    ))
      return 'A user with this email already exists.';
    return null;
  }

  void addUser({
    required String name,
    required String email,
    required UserRole role,
  }) {
    final now = DateTime.now();
    _users.insert(
      0,
      ManagedUser(
        id: 'USR-${now.microsecondsSinceEpoch % 1000000}',
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        isActive: true,
        createdAt: now,
      ),
    );
  }

  void updateUser(
    String id, {
    required String name,
    required String email,
    required UserRole role,
  }) {
    final i = _users.indexWhere((u) => u.id == id);
    if (i < 0) throw StateError('User not found.');
    _users[i] = _users[i].copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: role,
    );
  }

  void setActive(String id, bool active) {
    final i = _users.indexWhere((u) => u.id == id);
    if (i < 0) throw StateError('User not found.');
    if (_users[i].role == UserRole.admin &&
        !active &&
        _users.where((u) => u.role == UserRole.admin && u.isActive).length <=
            1) {
      throw StateError('At least one active administrator must remain.');
    }
    _users[i] = _users[i].copyWith(isActive: active);
  }

  void deleteUser(String id) {
    final matches = _users.where((item) => item.id == id);
    if (matches.isEmpty) return;
    final u = matches.first;
    if (u.role == UserRole.admin &&
        u.isActive &&
        _users
                .where((item) => item.role == UserRole.admin && item.isActive)
                .length <=
            1) {
      throw StateError('The last active administrator cannot be deleted.');
    }
    _users.removeWhere((item) => item.id == id);
  }
}
