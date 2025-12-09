import 'dart:convert';
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
  
  // Helper to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      'bypass-tunnel-reminder': 'true', // Needed for LocalTunnel
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('GET $url');
      final response = await http.get(url, headers: headers)
          .timeout(ApiConfig.requestTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('\n📤 API CLIENT: POST Request');
      print('   - URL: $url');
      print('   - Headers: $headers');
      print('   - Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        url, 
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.requestTimeout);
      
      print('📥 API CLIENT: Response received');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ API CLIENT: POST request failed');
      print('   - Endpoint: $endpoint');
      print('   - Error: $e');
      print('   - Error Type: ${e.runtimeType}');
      throw _handleError(e);
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('PUT $url');
      final response = await http.put(
        url, 
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.requestTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      
      print('DELETE $url');
      final response = await http.delete(url, headers: headers)
          .timeout(ApiConfig.requestTimeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file (Multipart)
  Future<dynamic> uploadFile(String endpoint, File file, {String fieldName = 'file'}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      // Remove Content-Type as multipart request sets it automatically with boundary
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      );
      request.files.add(multipartFile);

      print('UPLOAD $url');
      final streamedResponse = await request.send().timeout(ApiConfig.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
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
