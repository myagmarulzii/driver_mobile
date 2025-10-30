import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  final _secureStorage = const FlutterSecureStorage();
  final _dbService = DatabaseService.instance;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize and check if user is already logged in
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      await _loadUser(userId);
    }
  }

  Future<void> _loadUser(String userId) async {
    final userMap = await _dbService.getUser(userId);
    if (userMap != null) {
      _currentUser = User.fromMap(userMap);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      // Hash password
      final hashedPassword = _hashPassword(password);

      // Check credentials from secure storage
      final storedPassword = await _secureStorage.read(key: 'pwd_$username');

      if (storedPassword == hashedPassword) {
        // Get user from database
        final userId = await _secureStorage.read(key: 'uid_$username');
        if (userId != null) {
          await _loadUser(userId);

          // Save session
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setInt('lastActivity', DateTime.now().millisecondsSinceEpoch);

          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Biometric authentication
  Future<bool> loginWithBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        // In production, add actual biometric check here
        await _loadUser(userId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Biometric login error: $e');
      return false;
    }
  }

  // Register new user (typically called by admin)
  Future<bool> registerUser(User user, String password) async {
    try {
      // Store user in database
      await _dbService.insertUser(user.toMap());

      // Store credentials securely
      final hashedPassword = _hashPassword(password);
      await _secureStorage.write(key: 'pwd_${user.username}', value: hashedPassword);
      await _secureStorage.write(key: 'uid_${user.username}', value: user.id);

      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    try {
      final oldHashed = _hashPassword(oldPassword);
      final storedPassword = await _secureStorage.read(key: 'pwd_${_currentUser!.username}');

      if (storedPassword == oldHashed) {
        final newHashed = _hashPassword(newPassword);
        await _secureStorage.write(
          key: 'pwd_${_currentUser!.username}',
          value: newHashed,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('lastActivity');

    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Check session timeout (30 minutes for admin, 4 hours for others)
  Future<bool> checkSessionTimeout() async {
    if (_currentUser == null) return true;

    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt('lastActivity');

    if (lastActivity == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeoutMinutes = _currentUser!.role == UserRole.admin ? 30 : 240;
    final timeoutMs = timeoutMinutes * 60 * 1000;

    if (now - lastActivity > timeoutMs) {
      await logout();
      return true;
    }

    // Update last activity
    await prefs.setInt('lastActivity', now);
    return false;
  }

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if user has permission for action
  bool hasPermission(String action) {
    if (_currentUser == null) return false;

    switch (action) {
      case 'manage_users':
        return _currentUser!.role == UserRole.admin ||
            _currentUser!.role == UserRole.superAdmin;
      case 'view_all_students':
        return _currentUser!.role == UserRole.admin;
      case 'start_session':
        return _currentUser!.role == UserRole.instructor;
      case 'submit_feedback':
        return _currentUser!.role == UserRole.student;
      default:
        return false;
    }
  }
}
