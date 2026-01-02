
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Stream to notify app when session expires (401 + refresh failed)
  static final StreamController<void> sessionExpiredController = StreamController<void>.broadcast();
  
  // Helper to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      'bypass-tunnel-reminder': 'true', // Needed for LocalTunnel
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic request handler with retry logic for token refresh
  Future<dynamic> _sendRequest(
    String method,
    String endpoint, {
    dynamic body,
    File? file,
    List<int>? fileBytes,
    String? filename,
    String fieldName = 'file',
  }) async {
    int retries = 1;
    while (true) {
      try {
        final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
        var headers = await _getHeaders();

        http.Response response;

        if (file != null || fileBytes != null) {
          // Upload file logic
          headers.remove('Content-Type'); // Multipart sets boundary
          final request = http.MultipartRequest(method, url);
          request.headers.addAll(headers);
          
          if (file != null) {
             final multipartFile = await http.MultipartFile.fromPath(fieldName, file.path);
             request.files.add(multipartFile);
          } else if (fileBytes != null) {
             final multipartFile = http.MultipartFile.fromBytes(
               fieldName, 
               fileBytes,
               filename: filename ?? 'upload',
             );
             request.files.add(multipartFile);
          }
          
          print('$method (Upload) $url'); // Log
          final streamed = await request.send().timeout(ApiConfig.requestTimeout);
          response = await http.Response.fromStream(streamed);
        } else {
          // Standard JSON request logic
          if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
             print('\n📤 API CLIENT: $method Request');
             print('   - URL: $url');
             // print('   - Headers: $headers'); 
             print('   - Body: ${jsonEncode(body)}');
          } else {
             print('$method $url');
          }

          switch (method) {
            case 'GET':
              response = await http.get(url, headers: headers).timeout(ApiConfig.requestTimeout);
              break;
            case 'POST':
              response = await http.post(
                url, 
                headers: headers, 
                body: body != null ? jsonEncode(body) : null
              ).timeout(ApiConfig.requestTimeout);
              break;
            case 'PUT':
              response = await http.put(
                url, 
                headers: headers, 
                body: body != null ? jsonEncode(body) : null
              ).timeout(ApiConfig.requestTimeout);
              break;
            case 'PATCH':
              response = await http.patch(
                url, 
                headers: headers, 
                body: body != null ? jsonEncode(body) : null
              ).timeout(ApiConfig.requestTimeout);
              break;
            case 'DELETE':
              response = await http.delete(url, headers: headers).timeout(ApiConfig.requestTimeout);
              break;
            default:
              throw Exception('Unsupported HTTP method: $method');
          }
          
          if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
              print('📥 API CLIENT: Response received');
              print('   - Status Code: ${response.statusCode}');
              print('   - Response Body: ${response.body}');
          }
        }

        return _handleResponse(response);

      } on ApiException catch (e) {
        // Handle Token Expiry
        if (e.statusCode == 401 && retries > 0) {
          print('⚠️ 401 Unauthorized - Attempting to refresh token...');
          try {
            final success = await _refreshToken();
            if (success) {
              print('✅ Token refreshed. Retrying request...');
              retries--;
              continue; // Retry loop
            } else {
               // Refresh returned false (e.g. refresh token itself expired)
               print('❌ Token refresh returned false. Session expired.');
               sessionExpiredController.add(null);
            }
          } catch (refreshError) {
             print('❌ Token refresh failed with error: $refreshError');
             sessionExpiredController.add(null);
          }
        }
        rethrow;
      } catch (e) {
        throw _handleError(e);
      }
    }
  }

  // Refresh Token Logic
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final url = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
      print('🔄 Refreshing Token...');

      // Call directly with http to avoid interceptor loop
      final response = await http.post(
        url,
        headers: {
            'Content-Type': 'application/json',
            'bypass-tunnel-reminder': 'true',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken']; // Check for new refresh token
        
        if (newAccessToken != null) {
           await _storage.write(key: _tokenKey, value: newAccessToken);
           
           // If backend rotates refresh tokens, save the new one!
           if (newRefreshToken != null) {
               print('🔄 Updating Refresh Token (Rotation detected)');
               await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
           }
           
           return true; 
        }
      }
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  // GET request
  Future<dynamic> get(String endpoint) {
    return _sendRequest('GET', endpoint);
  }

  // POST request
  Future<dynamic> post(String endpoint, {dynamic body}) {
    return _sendRequest('POST', endpoint, body: body);
  }

  // PUT request
  Future<dynamic> put(String endpoint, {dynamic body}) {
    return _sendRequest('PUT', endpoint, body: body);
  }

  // PATCH request
  Future<dynamic> patch(String endpoint, {dynamic body}) {
    return _sendRequest('PATCH', endpoint, body: body);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) {
    return _sendRequest('DELETE', endpoint);
  }

  // Upload file
  Future<dynamic> uploadFile(String endpoint, {File? file, List<int>? fileBytes, String? filename, String fieldName = 'file'}) {
    return _sendRequest('POST', endpoint, file: file, fileBytes: fileBytes, filename: filename, fieldName: fieldName);
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      
      String message = 'Unknown error occurred';
      try {
        final errorBody = jsonDecode(response.body);
        message = errorBody['message'] ?? errorBody['error'] ?? message;
      } catch (_) {}
      
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
      );
    }
  }

  // Handle exceptions
  Exception _handleError(dynamic error) {
    print('Network Error: $error');
    if (error is ApiException) return error;
    if (error is SocketException) return Exception('No internet connection');
    if (error is http.ClientException) return Exception('Connection failed');
    return Exception('Something went wrong: $error');
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
