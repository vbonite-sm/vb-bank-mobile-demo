import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isDarkTheme = true;
  bool _isReturningUser = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isDarkTheme => _isDarkTheme;
  bool get isBiometricEnabled => _storage.isBiometricEnabled;
  /// True if the user has logged in before (for smart greeting)
  bool get isReturningUser => _isReturningUser;

  /// Initialize auth state from stored session
  Future<void> init() async {
    _isDarkTheme = _storage.isDarkTheme;
    AppColors.isDark = _isDarkTheme;
    final session = _authService.getCurrentSession();
    if (session != null) {
      _currentUser = _authService.getCurrentUser();
    }
    notifyListeners();
  }

  /// Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);

      if (result['success']) {
        _currentUser = _authService.getCurrentUser();
        _error = null;
      } else {
        _error = result['error'];
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = 'An error occurred';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        phone: phone,
      );

      if (result['success']) {
        _currentUser = _authService.getCurrentUser();
        _error = null;
      } else {
        _error = result['error'];
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = 'Registration failed';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_currentUser == null) {
      return {'success': false, 'error': 'Not logged in'};
    }

    final result = await _authService.changePassword(
      _currentUser!.id,
      currentPassword,
      newPassword,
    );

    if (result['success']) {
      _currentUser = _authService.getCurrentUser();
      notifyListeners();
    }

    return result;
  }

  /// Update profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> updates) async {
    if (_currentUser == null) {
      return {'success': false, 'error': 'Not logged in'};
    }

    final result = await _authService.updateProfile(_currentUser!.id, updates);

    if (result['success']) {
      _currentUser = _authService.getCurrentUser();
      notifyListeners();
    }

    return result;
  }

  /// Toggle theme
  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    AppColors.isDark = _isDarkTheme;
    await _storage.setTheme(_isDarkTheme);
    notifyListeners();
  }

  /// Toggle biometric
  Future<void> toggleBiometric(bool enabled) async {
    await _storage.setBiometricEnabled(enabled);
    notifyListeners();
  }

  /// Refresh user data
  void refreshUser() {
    if (_currentUser != null) {
      _currentUser = _storage.getUserById(_currentUser!.id);
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
