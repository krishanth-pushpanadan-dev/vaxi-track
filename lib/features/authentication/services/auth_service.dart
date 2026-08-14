import '../models/user_model.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  UserModel? _currentUser;

  /// Currently logged-in user
  UserModel? get currentUser => _currentUser;

  /// Check whether a user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Login user
  void login(UserModel user) {
    _currentUser = user;
  }

  /// Logout user
  void logout() {
    _currentUser = null;
  }

  /// Check current user's role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Check whether current user has any of the given roles
  bool hasAnyRole(List<UserRole> roles) {
    if (_currentUser == null) {
      return false;
    }

    return roles.contains(_currentUser!.role);
  }
}
