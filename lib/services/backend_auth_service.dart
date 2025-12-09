import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../config/api_config.dart';

class BackendAuthService {
  static final BackendAuthService _instance = BackendAuthService._internal();
  factory BackendAuthService() => _instance;
  BackendAuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Request OTP
  Future<bool> requestOtp(String email) async {
    try {
      await _apiClient.post(
        ApiConfig.requestOtpEndpoint,
        body: {'email': email},
      );
      return true;
    } catch (e) {
      print('Request OTP failed: $e');
      rethrow;
    }
  }

  // Verify OTP and Login
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtpEndpoint,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      final token = response['token'];
      final user = response['user'];

      if (token != null) {
        await _storage.write(key: _tokenKey, value: token);
      }
      
      if (user != null) {
        await _storage.write(key: _userKey, value: jsonEncode(user));
      }

      return {
        'user': user,
        'isNewUser': response['isNewUser'] ?? false,
        'token': token,
      };
    } catch (e) {
      print('Verify OTP failed: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Get stored user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userStr = await _storage.read(key: _userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }
}
