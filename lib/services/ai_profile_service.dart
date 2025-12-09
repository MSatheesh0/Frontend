import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// AI Profile data model
class AIProfileData {
  final String summary;
  final List<String> currentFocus;
  final List<String> strengths;
  final List<String> highlights;
  final DateTime? generatedAt;
  final DateTime? lastUpdated;

  AIProfileData({
    required this.summary,
    required this.currentFocus,
    required this.strengths,
    required this.highlights,
    this.generatedAt,
    this.lastUpdated,
  });

  factory AIProfileData.fromJson(Map<String, dynamic> json) {
    return AIProfileData(
      summary: json['summary'] ?? '',
      currentFocus: (json['currentFocus'] as List?)?.cast<String>() ?? [],
      strengths: (json['strengths'] as List?)?.cast<String>() ?? [],
      highlights: (json['highlights'] as List?)?.cast<String>() ?? [],
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'currentFocus': currentFocus,
        'strengths': strengths,
        'highlights': highlights,
        'generatedAt': generatedAt?.toIso8601String(),
        'lastUpdated': lastUpdated?.toIso8601String(),
      };
}

/// Service for managing AI-generated profile content
class AIProfileService {
  /// Get AI profile content
  Future<AIProfileData> getAIProfile(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me/ai-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ AI Profile fetched successfully');
        return AIProfileData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        // No AI profile yet - return empty data
        print('ℹ️  No AI profile found - returning empty data');
        return AIProfileData(
          summary: '',
          currentFocus: [],
          strengths: [],
          highlights: [],
        );
      } else {
        // Parse error message from backend
        String errorMessage = 'Failed to fetch AI profile';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = 'AI Profile Error: ${errorData['error']}';
          }
          if (errorData['message'] != null) {
            errorMessage = 'AI Profile Error: ${errorData['message']}';
          }
        } catch (_) {
          // If parsing fails, use default message
        }
        print('❌ AI Profile API Error (${response.statusCode}): $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Regenerate AI profile content
  Future<AIProfileData> regenerateAIProfile(
    String authToken, {
    bool includeGoals = true,
    bool includeDocuments = true,
    String tone = 'professional',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/me/ai-profile/regenerate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'includeGoals': includeGoals,
          'includeDocuments': includeDocuments,
          'tone': tone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ AI Profile regenerated successfully');
        return AIProfileData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to regenerate AI profile');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }
}
