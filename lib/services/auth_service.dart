import 'storage_service.dart';
import '../models/user.dart';

class AuthService {
  final StorageService _storage = StorageService.instance;

  /// Login user with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final user = _storage.getUserByUsername(username);

      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      if (user.password != password) {
        return {'success': false, 'error': 'Invalid password'};
      }

      // Create session
      final session = {
        'userId': user.id,
        'username': user.username,
        'fullName': user.fullName,
        'role': user.role,
        'accountNumber': user.accountNumber,
        'email': user.email,
      };

      await _storage.saveSession(session);
      await _storage.setSavedUsername(username);

      return {'success': true, 'user': session};
    } catch (e) {
      return {'success': false, 'error': 'Login failed: ${e.toString()}'};
    }
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    try {
      // Check if username exists
      final existing = _storage.getUserByUsername(username);
      if (existing != null) {
        return {'success': false, 'error': 'Username already exists'};
      }

      // Check if email exists
      final users = _storage.getUsers();
      final emailExists = users.any(
          (u) => u.email.toLowerCase() == email.toLowerCase());
      if (emailExists) {
        return {'success': false, 'error': 'Email already registered'};
      }

      // Generate account number
      final accountNumber = _generateAccountNumber();

      // Generate user ID
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final newUser = User(
        id: userId,
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        role: 'user',
        accountNumber: accountNumber,
        balance: 1000.00, // Welcome bonus
        currency: 'USD',
        crypto: {'BTC': 0.0, 'ETH': 0.0},
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _storage.saveUser(newUser);

      // Auto-login
      return await login(username, password);
    } catch (e) {
      return {'success': false, 'error': 'Registration failed: ${e.toString()}'};
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _storage.clearSession();
  }

  /// Get current session
  Map<String, dynamic>? getCurrentSession() {
    return _storage.getSession();
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _storage.getSession() != null;
  }

  /// Get current logged-in user
  User? getCurrentUser() {
    final session = _storage.getSession();
    if (session == null) return null;
    return _storage.getUserById(session['userId']);
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _storage.getUserById(userId);
      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      if (user.password != currentPassword) {
        return {'success': false, 'error': 'Current password is incorrect'};
      }

      user.password = newPassword;
      await _storage.saveUser(user);

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to change password'};
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final user = _storage.getUserById(userId);
      if (user == null) {
        return {'success': false, 'error': 'User not found'};
      }

      if (updates.containsKey('fullName')) user.fullName = updates['fullName'];
      if (updates.containsKey('email')) user.email = updates['email'];
      if (updates.containsKey('phone')) user.phone = updates['phone'];
      if (updates.containsKey('address')) user.address = updates['address'];

      await _storage.saveUser(user);

      // Update session
      final session = _storage.getSession();
      if (session != null) {
        session['fullName'] = user.fullName;
        session['email'] = user.email;
        await _storage.saveSession(session);
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to update profile'};
    }
  }

  /// Generate a unique 10-digit account number
  String _generateAccountNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final accountNum = timestamp.substring(timestamp.length - 10);
    return accountNum;
  }
}
