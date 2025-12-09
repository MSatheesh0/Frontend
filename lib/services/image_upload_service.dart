import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_client.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

class ImageUploadService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  /// Upload profile image to backend (which uploads to Cloudinary)
  /// Works on both mobile and web platforms
  Future<String> uploadProfileImage(dynamic imageFile) async {
    try {
      print('📤 Uploading profile image...');
      
      // Get auth token
      final token = _authService.authToken;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/users/upload-profile-image'),
      );

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file - different approach for web vs mobile
      if (kIsWeb) {
        // Web platform - imageFile is XFile
        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.name;
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: fileName,
          ),
        );
      } else {
        // Mobile platform - imageFile is File
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      print('📤 Sending image upload request...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['imageUrl'] as String;
        
        print('✅ Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('❌ Image upload failed: $e');
      rethrow;
    }
  }
}
