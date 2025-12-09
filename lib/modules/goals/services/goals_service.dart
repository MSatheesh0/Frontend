import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Goal data model from backend API
class GoalAPI {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String status;
  final int progress;
  final DateTime? targetDate;
  final List<Milestone> milestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalAPI({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.status,
    required this.progress,
    this.targetDate,
    required this.milestones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalAPI.fromJson(Map<String, dynamic> json) {
    return GoalAPI(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      status: json['status'],
      progress: json['progress'] ?? 0,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
      milestones: (json['milestones'] as List?)
              ?.map((m) => Milestone.fromJson(m))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'status': status,
        'progress': progress,
        'targetDate': targetDate?.toIso8601String(),
        'milestones': milestones.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Milestone model
class Milestone {
  final String id;
  final String title;
  final bool completed;
  final DateTime? completedAt;

  Milestone({
    required this.id,
    required this.title,
    required this.completed,
    this.completedAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };
}

/// Service for managing user goals via backend API
class GoalsService {
  /// Get user's goals
  Future<List<GoalAPI>> getGoals(
    String authToken, {
    String? status,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/me/goals')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final goals =
            (data['goals'] as List).map((g) => GoalAPI.fromJson(g)).toList();
        print('✅ Fetched ${goals.length} goals');
        return goals;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        // Parse error message from backend
        String errorMessage = 'Failed to fetch goals';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMessage = 'Goals Error: ${errorData['error']}';
          }
          if (errorData['message'] != null) {
            errorMessage = 'Goals Error: ${errorData['message']}';
          }
        } catch (_) {
          // If parsing fails, use default message
        }
        print('❌ Goals API Error (${response.statusCode}): $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Create a new goal
  Future<GoalAPI> createGoal(
    String authToken, {
    required String title,
    String? description,
    required String category,
    DateTime? targetDate,
    List<String>? milestones,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/me/goals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': title,
          if (description != null) 'description': description,
          'category': category,
          if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
          if (milestones != null)
            'milestones': milestones.map((m) => {'title': m}).toList(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Goal created successfully');
        return GoalAPI.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to create goal');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Update an existing goal
  Future<GoalAPI> updateGoal(
    String authToken,
    String goalId, {
    String? title,
    String? description,
    int? progress,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (progress != null) updateData['progress'] = progress;
      if (status != null) updateData['status'] = status;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/me/goals/$goalId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Goal updated successfully');
        return GoalAPI.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to update goal');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(
    String authToken,
    String goalId, {
    bool archive = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/me/goals/$goalId')
          .replace(queryParameters: archive ? {'archive': 'true'} : null);

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Goal ${archive ? "archived" : "deleted"} successfully');
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to delete goal');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Network error. Please check your connection.');
    }
  }
}
