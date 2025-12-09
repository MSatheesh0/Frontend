import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simplified Authentication service with email/password
/// Data stored in db.json
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Map<String, dynamic>? _currentUser;
  String? _authToken;

  /// Get current authenticated user
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  /// Get auth token
  String? get authToken => _authToken;

  /// Load database
  Future<Map<String, dynamic>> _loadDatabase() async {
    final jsonString = await rootBundle.loadString('assets/data/db.json');
    return jsonDecode(jsonString);
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final db = await _loadDatabase();
    final users = db['users'] as List;

    // Find user
    final user = users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => null,
    );

    if (user == null) {
      throw Exception('Invalid email or password');
    }

    // Create session
    _authToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = Map<String, dynamic>.from(user);
    _currentUser!.remove('password'); // Don't store password in memory

    // Save to secure storage
    await _secureStorage.write(key: _tokenKey, value: _authToken);
    await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));

    print('✅ [MOCK] Signed in: ${user['email']}');
    return _currentUser!;
  }

  /// Sign up new user
  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final db = await _loadDatabase();
    final users = db['users'] as List;

    // Check if email already exists
    final existingUser = users.any((u) => u['email'] == userData['email']);
    if (existingUser) {
      throw Exception('Email already registered');
    }

    // Create new user
    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      ...userData,
    };

    // In a real app, we would save to db.json here
    // For now, we'll just simulate it
    print('✅ [MOCK] New user registered: ${userData['email']}');
    print('📝 User data: ${jsonEncode(newUser)}');

    // Create session
    _authToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = Map<String, dynamic>.from(newUser);
    _currentUser!.remove('password'); // Don't store password in memory

    // Save to secure storage
    await _secureStorage.write(key: _tokenKey, value: _authToken);
    await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));

    return _currentUser!;
  }

  /// Sign out user
  Future<void> signOut() async {
    _currentUser = null;
    _authToken = null;

    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);

    print('✅ User signed out');
  }

  /// Restore session from secure storage
  Future<bool> restoreSession() async {
    try {
      final storedToken = await _secureStorage.read(key: _tokenKey);
      final storedUserJson = await _secureStorage.read(key: _userKey);

      if (storedToken != null && storedUserJson != null) {
        _authToken = storedToken;
        _currentUser = jsonDecode(storedUserJson) as Map<String, dynamic>;

        print('✅ Session restored for ${_currentUser!['email']}');
        return true;
      }

      print('ℹ️  No saved session found');
      return false;
    } catch (e) {
      print('⚠️  Failed to restore session: $e');
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      return false;
    }
  }
}
