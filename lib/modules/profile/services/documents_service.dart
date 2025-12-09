import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Document model from backend API
class DocumentAPI {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String url;
  final DateTime uploadedAt;
  final int? size;
  final Map<String, dynamic>? metadata;

  DocumentAPI({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.url,
    required this.uploadedAt,
    this.size,
    this.metadata,
  });

  factory DocumentAPI.fromJson(Map<String, dynamic> json) {
    return DocumentAPI(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      url: json['url'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      size: json['size'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'url': url,
        'uploadedAt': uploadedAt.toIso8601String(),
        'size': size,
        'metadata': metadata,
      };
}

/// Service for managing user documents via backend API
class DocumentsService {
  /// Get all documents
  Future<List<DocumentAPI>> getDocuments(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me/documents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = (data['documents'] as List)
            .map((d) => DocumentAPI.fromJson(d))
            .toList();
        print('✅ Fetched ${documents.length} documents');
        return documents;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        // Parse error message from backend
        String errorMessage = 'Failed to fetch documents';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = 'Documents Error: ${errorData['error']}';
          }
          if (errorData['message'] != null) {
            errorMessage = 'Documents Error: ${errorData['message']}';
          }
        } catch (_) {
          // If parsing fails, use default message
        }
        print('❌ Documents API Error (${response.statusCode}): $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Upload a file document
  Future<DocumentAPI> uploadFile(
    String authToken, {
    required File file,
    required String title,
    String? description,
    String type = 'pdf',
    String? category,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/me/documents'),
      );

      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['title'] = title;
      request.fields['type'] = type;
      // TEMPORARY WORKAROUND: Backend incorrectly requires 'url' for file uploads
      // This should be removed once backend is fixed to differentiate file uploads from links
      request.fields['url'] = '';
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Document uploaded successfully');
        return DocumentAPI.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to upload document');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Add a link document
  Future<DocumentAPI> addLink(
    String authToken, {
    required String title,
    required String url,
    String? description,
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/me/documents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': title,
          'url': url,
          'type': 'link',
          if (description != null) 'description': description,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Link added successfully');
        return DocumentAPI.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to add link');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String authToken, String documentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/me/documents/$documentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Document deleted successfully');
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }
}
