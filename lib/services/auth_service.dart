import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../config/api_config.dart';

/// Authentication service using Backend OTP flow
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Register callback for background token refreshes
    ApiClient.onTokenRefreshed = updateToken;
  }

  final _secureStorage = const FlutterSecureStorage();
  final _apiClient = ApiClient();
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _deviceIdKey = 'device_id';

  Map<String, dynamic>? _currentUser;
  String? _authToken;

  /// Get current authenticated user
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _currentUser != null;

  /// Get auth token
  String? get authToken => _authToken;

  /// Update auth token in memory (called by ApiClient after refresh)
  void updateToken(String token) {
    _authToken = token;
  }

  /// Get Device ID (persistent per install)
  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    if (deviceId == null) {
      deviceId = 'mobile_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  /// Request OTP for email
  Future<void> requestOtp(String email) async {
    try {
      await _apiClient.post(
        ApiConfig.requestOtpEndpoint,
        body: {'email': email},
      );
      print('✅ OTP requested for: $email');
    } catch (e) {
      print('❌ Request OTP failed: $e');
      rethrow;
    }
  }

  /// Verify OTP and Sign In
  Future<Map<String, dynamic>> verifyOtp(String email, String otp, {bool logoutFromOtherDevices = false}) async {
    try {
      final deviceId = await _getOrCreateDeviceId();
      final response = await _apiClient.post(
        ApiConfig.verifyOtpEndpoint,
        body: {
          'email': email,
          'otp': otp,
          'deviceId': deviceId,
          'deviceInfo': 'Mobile App (WayTree)',
          if (logoutFromOtherDevices) 'logoutFromOtherDevices': true,
        },
      );

      final accessToken = response['accessToken'];
      final refreshToken = response['refreshToken'];
      final user = response['user'];
      final isNewUser = response['isNewUser'] == true;

      // Handle successful login
      if (accessToken == null || user == null) {
        throw Exception('Invalid response from server');
      }

      // Create session
      _authToken = accessToken;
      _currentUser = Map<String, dynamic>.from(user);

      // Save to secure storage
      await _secureStorage.write(key: _tokenKey, value: _authToken);
      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));

      print('✅ Signed in: ${user['email']} (New User: $isNewUser)');
      
      // Return both user and isNewUser flag
      return {
        'user': _currentUser,
        'isNewUser': isNewUser,
      };
    } catch (e) {
      print('❌ Verify OTP failed: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    if (ApiConfig.useMockAuth) {
      print('⚠️ Using Mock Auth for SignIn');
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = {
        'id': 'mock_user_1',
        'email': email,
        'name': 'Mock User',
        'role': 'Developer',
        'company': 'Mock Inc',
        'photoUrl': '',
        'bio': 'This is a mock user for local development.',
      };
      _authToken = 'mock_token_123';
      
      await _secureStorage.write(key: _tokenKey, value: _authToken);
      await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));
      return _currentUser!;
    }

    throw Exception('Please use OTP authentication');
  }

  /// Sign up new user
  Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    if (ApiConfig.useMockAuth) {
      print('⚠️ Using Mock Auth for SignUp');
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = {
        'id': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        ...userData,
      };
      _authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await _secureStorage.write(key: _tokenKey, value: _authToken);
      await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));
      return _currentUser!;
    }

    throw Exception('Please use OTP authentication');
  }

  /// Fetch latest user profile from backend
  Future<Map<String, dynamic>> fetchUserProfile() async {
    if (_authToken == null) throw Exception('No user logged in');
    
    try {
      final user = await _apiClient.get(ApiConfig.userProfileEndpoint);
      if (user != null) {
        _currentUser = Map<String, dynamic>.from(user);
        await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));
        print('✅ User profile fetched and updated');
        return _currentUser!;
      }
      throw Exception('Empty response');
    } catch (e) {
      print('❌ Fetch profile failed: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> updates) async {
    if (_authToken == null) {
      throw Exception('No user logged in');
    }

    try {
      final updatedUser = await _apiClient.put(
        ApiConfig.userProfileEndpoint,
        body: updates,
      );
      
      // Update current user in memory
      _currentUser = Map<String, dynamic>.from(updatedUser);
      
      // Update secure storage
      await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));
      
      print('✅ Profile updated for: ${updatedUser['email']}');
      return _currentUser!;
    } catch (e) {
      print('❌ Update profile failed: $e');
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        // Notify backend to invalidate the session
        await _apiClient.post('/auth/logout', body: {'refreshToken': refreshToken});
      }
    } catch (e) {
      print('⚠️ Backend logout failed (skipping): $e');
    } finally {
      // Always clear local state
      _currentUser = null;
      _authToken = null;

      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userKey);
      // We keep _deviceIdKey so the device remains uniquely identified permanently

      print('✅ User signed out locally');
    }
  }

  /// Restore session from secure storage
  Future<bool> restoreSession() async {
    try {
      final storedToken = await _secureStorage.read(key: _tokenKey);
      final storedUserJson = await _secureStorage.read(key: _userKey);

      if (storedToken != null && storedUserJson != null) {
        _authToken = storedToken;
        _currentUser = jsonDecode(storedUserJson) as Map<String, dynamic>;

        // Optionally verify token with backend
        // try {
        //   final user = await _apiClient.get(ApiConfig.userProfileEndpoint);
        //   _currentUser = user;
        //   await _secureStorage.write(key: _userKey, value: jsonEncode(_currentUser));
        // } catch (e) {
        //   print('⚠️ Token might be expired: $e');
        //   // Decide whether to logout or keep local session
        // }

        print('✅ Session restored for ${_currentUser!['email']}');
        return true;
      }

      print('ℹ️  No saved session found');
      return false;
    } catch (e) {
      print('⚠️  Failed to restore session: $e');
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userKey);
      return false;
    }
  }
}
