import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_client.dart';
import '../config/api_config.dart';

/// Service for managing network codes, QR profiles, and connections
/// Now connected to backend API
class NetworkingService {
  static final NetworkingService _instance = NetworkingService._internal();
  factory NetworkingService() => _instance;
  NetworkingService._internal();

  final _apiClient = ApiClient();

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  /// Get user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    if (ApiConfig.useMockAuth) {
      // Mock data
      return {
        'id': userId,
        'name': 'Mock User',
        'role': 'Developer',
        'company': 'Mock Inc',
        'photoUrl': '',
        'bio': 'Mock bio',
      };
    }

    try {
      // The backend route is defined in userRoutes.ts as router.get("/:id", ...)
      // And server.ts mounts userRoutes at "/users"
      // So the correct URL is /users/$userId
      return await _apiClient.get('/users/$userId');
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email, String password) async {
    throw Exception('Use AuthService.signIn (OTP) instead');
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    throw Exception('Use AuthService.signUp (OTP) instead');
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updates) async {
     if (ApiConfig.useMockAuth) {
       return {
         'id': userId,
         ...updates,
       };
     }
     return await _apiClient.put(ApiConfig.userProfileEndpoint, body: updates);
  }

  // ============================================================================
  // NETWORK CODE MANAGEMENT
  // ============================================================================

  /// Create a new network code
  Future<Map<String, dynamic>> createNetworkCode({
    required String userId,
    required String code,
    required String name,
    required String description,
    required bool autoConnect,
    required DateTime expiresAt,
    int maxConnections = 100,
    List<String> tags = const [],
  }) async {
    if (ApiConfig.useMockAuth) {
      print('⚠️ Using Mock Network Code Create');
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'id': 'mock_nc_${DateTime.now().millisecondsSinceEpoch}',
        'code': code,
        'codeId': code,
        'name': name,
        'description': description,
        'autoConnect': autoConnect,
        'expirationTime': expiresAt.toIso8601String(),
        'keywords': tags,
        'createdBy': userId,
      };
    }

    try {
      final body = {
        'codeId': code,
        'name': name,
        'description': description,
        'autoConnect': autoConnect,
        'expirationTime': expiresAt.toIso8601String(),
        'keywords': tags,
      };

      final response = await _apiClient.post(ApiConfig.networkCodesEndpoint, body: body);
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        print('✅ Created network code: ${response['data']['codeId']}');
        return response['data'];
      }
      
      print('✅ Created network code: ${response['codeId']}');
      return response;
    } catch (e) {
      print('❌ Create network code failed: $e');
      rethrow;
    }
  }

  /// Update network code
  Future<Map<String, dynamic>> updateNetworkCode({
    required String networkCodeId,
    String? name,
    String? description,
    bool? autoConnect,
    DateTime? expiresAt,
    bool? isActive,
    int? maxConnections,
    List<String>? tags,
  }) async {
    if (ApiConfig.useMockAuth) {
      return {
        'id': networkCodeId,
        'name': name ?? 'Updated Name',
        'autoConnect': autoConnect ?? false,
      };
    }

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (autoConnect != null) body['autoConnect'] = autoConnect;
      if (expiresAt != null) body['expirationTime'] = expiresAt.toIso8601String();
      if (tags != null) body['keywords'] = tags;

      final response = await _apiClient.put(
        '${ApiConfig.networkCodesEndpoint}/$networkCodeId', 
        body: body
      );
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        print('✅ Updated network code: $networkCodeId');
        return response['data'];
      }
      
      print('✅ Updated network code: $networkCodeId');
      return response;
    } catch (e) {
      print('❌ Update network code failed: $e');
      rethrow;
    }
  }

  /// Delete network code and all associated connections
  Future<void> deleteNetworkCode(String networkCodeId) async {
    if (ApiConfig.useMockAuth) {
      print('✅ Mock: Deleted network code: $networkCodeId');
      return;
    }

    try {
      await _apiClient.delete('${ApiConfig.networkCodesEndpoint}/$networkCodeId');
      print('✅ Deleted network code: $networkCodeId');
    } catch (e) {
      print('❌ Delete network code failed: $e');
      rethrow;
    }
  }

  /// Get all network codes created by a user
  Future<List<Map<String, dynamic>>> getUserNetworkCodes(String userId) async {
    if (ApiConfig.useMockAuth) {
      return [
        {
          'id': 'mock_nc_1',
          'code': 'MOCK-EVENT',
          'codeId': 'MOCK-EVENT',
          'name': 'Mock Event',
          'description': 'A mock event for testing',
          'autoConnect': true,
          'keywords': ['Tech', 'Mock'],
          'createdBy': userId,
        }
      ];
    }

    try {
      final response = await _apiClient.get('${ApiConfig.networkCodesEndpoint}/user/$userId');
      
      // Handle wrapped response with 'data' field
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get user network codes failed: $e');
      return [
        {
          'id': 'mock_conn_1',
          'userId1': userId,
          'userId2': 'mock_user_2',
          'status': 'connected',
          'connectedAt': DateTime.now().toIso8601String(),
          'connectionSource': 'direct',
          'notes': 'Mock connection',
          'tags': ['Mock'],
        }
      ];
    }

    try {
      final response = await _apiClient.get('${ApiConfig.connectionsEndpoint}/my-connections?status=accepted');
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get user connections failed: $e');
      return [];
    }
  }

  /// Get pending connection requests for a user
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    if (ApiConfig.useMockAuth) {
      return [];
    }

    try {
      final response = await _apiClient.get('${ApiConfig.connectionsEndpoint}/my-connections?status=pending&type=received');
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get pending requests failed: $e');
      return [];
    }
  }

  /// Approve connection request
  Future<Map<String, dynamic>> approveRequest(String requestId) async {
    if (ApiConfig.useMockAuth) {
      return {'status': 'accepted'};
    }

    try {
      final body = {'status': 'accepted'};
      final response = await _apiClient.put('${ApiConfig.connectionsEndpoint}/$requestId/status', body: body);
      print('✅ Approved request: $requestId');
      return response;
    } catch (e) {
      print('❌ Approve request failed: $e');
      rethrow;
    }
  }
  
  /// Find network code by code string
  Future<Map<String, dynamic>?> findNetworkCodeByCode(String code) async {
    print('\n🔍 API: findNetworkCodeByCode called');
    print('   - Code: $code');
    print('   - Endpoint: ${ApiConfig.networkCodesEndpoint}/$code');
    
    if (ApiConfig.useMockAuth) {
      print('⚠️ API: Using MOCK AUTH mode');
      if (code == 'MOCK-EVENT') {
        return {
          'id': 'mock_nc_1',
          'code': 'MOCK-EVENT',
          'codeId': 'MOCK-EVENT',
          'name': 'Mock Event',
          'description': 'A mock event',
          'autoConnect': true,
          'keywords': ['Tech'],
          'isActive': true,
        };
      }
      return null;
    }

    try {
      print('🔗 API: Making GET request...');
      final response = await _apiClient.get('${ApiConfig.networkCodesEndpoint}/$code');
      print('✅ API: Response received');
      print('📊 API: Response type: ${response.runtimeType}');
      print('📊 API: Response: ${response.toString()}');
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        print('✅ API: Found network code in wrapped response');
        return Map<String, dynamic>.from(response['data']);
      }
      
      print('✅ API: Returning direct response');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ API: findNetworkCodeByCode failed');
      print('🔴 API: Error: $e');
      return null;
    }
  }

  /// Join network code
  Future<Map<String, dynamic>> joinNetworkCode({
    required String userId,
    required String code,
  }) async {
    print('\n🔗 API: joinNetworkCode called');
    print('   - User ID: $userId');
    print('   - Code ID: $code');
    print('   - Endpoint: ${ApiConfig.connectionsEndpoint}/connect');
    
    if (ApiConfig.useMockAuth) {
      print('⚠️ API: Using MOCK AUTH mode');
      return {
        'success': true,
        'message': 'Joined mock network',
        'autoConnect': true,
        'status': 'accepted',
      };
    }

    try {
      final body = {
        'codeId': code,
        'message': 'Joined via app',
      };
      
      print('📦 API: Request body: ${jsonEncode(body)}');
      print('🔗 API: Making POST request...');
      
      final response = await _apiClient.post('${ApiConfig.connectionsEndpoint}/connect', body: body);
      
      print('✅ API: Connection response received!');
      print('📊 API: Response type: ${response.runtimeType}');
      print('📊 API: Response: ${response.toString()}');
      print('✅ API: Joined network code: $code');
      
      return response;
    } catch (e) {
      print('❌ API: Join network code FAILED');
      print('🔴 API: Error details: $e');
      print('🔴 API: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Get user's connections
  Future<List<Map<String, dynamic>>> getUserConnections(String userId) async {
    if (ApiConfig.useMockAuth) {
      return [
        {
          'id': 'mock_conn_1',
          'userId1': userId,
          'userId2': 'mock_user_2',
          'status': 'connected',
          'connectedAt': DateTime.now().toIso8601String(),
          'connectionSource': 'direct',
          'notes': 'Mock connection',
          'tags': ['Mock'],
        }
      ];
    }

    try {
      final response = await _apiClient.get('${ApiConfig.connectionsEndpoint}/my-connections?status=accepted');
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get user connections failed: $e');
      return [];
    }
  }

  /// Get members connected via a specific network code
  Future<List<Map<String, dynamic>>> getNetworkCodeMembers(String networkCodeId) async {
    if (ApiConfig.useMockAuth) {
      return [];
    }

    try {
      final response = await _apiClient.get('${ApiConfig.connectionsEndpoint}/network-code/$networkCodeId/members');
      
      // Handle wrapped response
      if (response is Map<String, dynamic>) {
        if (response.containsKey('members') && response['members'] is List) {
          return List<Map<String, dynamic>>.from(response['members']);
        }
        
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) {
            return List<Map<String, dynamic>>.from(data);
          }
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get network members failed: $e');
      return [];
    }
  }

  /// Create QR Profile
  Future<Map<String, dynamic>> createQRProfile({
    required String userId,
    required String title,
    required String description,
    required String context,
    String customMessage = '',
  }) async {
    if (ApiConfig.useMockAuth) {
      return {
        'id': 'qr_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'title': title,
        'description': description,
        'context': context,
        'qrCodeId': 'qr_${DateTime.now().millisecondsSinceEpoch}',
        'customMessage': customMessage,
      };
    }

    try {
      final body = {
        'title': title,
        'description': description,
        'context': context,
        'qrCodeId': 'qr_${DateTime.now().millisecondsSinceEpoch}',
        'customMessage': customMessage,
      };

      final response = await _apiClient.post('/qr-profiles', body: body);
      
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        print('✅ Created QR profile: ${response['data']['qrCodeId']}');
        return response['data'];
      }
      
      print('✅ Created QR profile');
      return response;
    } catch (e) {
      print('❌ Create QR profile failed: $e');
      rethrow;
    }
  }

  /// Find QR Profile by ID
  Future<Map<String, dynamic>?> findQRProfileById(String qrProfileId) async {
    if (ApiConfig.useMockAuth) {
      return {
        'id': qrProfileId,
        'userId': 'mock_user_1',
        'title': 'Mock QR Profile',
        'description': 'Mock description',
        'context': 'Networking',
        'qrCodeId': qrProfileId,
      };
    }

    try {
      final response = await _apiClient.get('/qr-profiles/$qrProfileId');
      
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      
      return response;
    } catch (e) {
      print('❌ Find QR profile failed: $e');
      return null;
    }
  }
  
  // Helper methods like _areUsersConnected, _requestExists, etc. are now handled by backend logic
  // and don't need to be exposed or implemented here.
  
  Future<Map<String, dynamic>> scanQRCode({
    required String scannerId,
    required String qrProfileId,
  }) async {
    if (ApiConfig.useMockAuth) {
      return {'success': true, 'message': 'Scanned mock QR'};
    }

    try {
      final response = await _apiClient.post('/qr-profiles/$qrProfileId/scan');
      print('✅ QR scan recorded');
      return response;
    } catch (e) {
      print('❌ QR scan failed: $e');
      rethrow;
    }
  }

  /// Connect to a user directly
  Future<Map<String, dynamic>> connectToUser({
    required String userId,
    required String targetUserId,
  }) async {
    if (ApiConfig.useMockAuth) {
      return {'success': true, 'message': 'Connected to mock user'};
    }

    try {
      // We use the 'follow' endpoint as a connection for now, or a specific connection endpoint if available.
      // Based on previous code, we used 'followProfile'.
      // But if we want a bidirectional connection, we might need a different endpoint.
      // For now, let's use the 'connect' endpoint which seems to be for Network Codes, but maybe we can adapt it?
      // Actually, looking at 'joinNetworkCode', it uses '/connect'.
      // Let's check if there is a direct user connection endpoint.
      // If not, we will use 'followProfile' as the implementation for 'connectToUser' for now,
      // as "following" is a form of connection in this app.
      
      return await followProfile(
        userId: userId, 
        followingId: targetUserId,
        type: 'connection',
        label: 'Direct Connection'
      );
    } catch (e) {
      print('❌ Connect to user failed: $e');
      rethrow;
    }
  }

  // Old uploadMedia method removed. New implementation is at the bottom of the file.
  // Keeping this comment to avoid confusion if searching for the old location.

  /// Reject connection request
  Future<void> rejectRequest(String requestId, {String reason = ''}) async {
    if (ApiConfig.useMockAuth) return;

    try {
      final body = {'status': 'rejected'};
      await _apiClient.put('${ApiConfig.connectionsEndpoint}/$requestId/status', body: body);
      print('✅ Rejected request: $requestId');
    } catch (e) {
      print('❌ Reject request failed: $e');
      rethrow;
    }
  }

  /// Get pending join requests for a specific network code
  Future<List<Map<String, dynamic>>> getNetworkJoinRequests(String networkCodeId) async {
    if (ApiConfig.useMockAuth) return [];

    try {
      final response = await _apiClient.get('${ApiConfig.connectionsEndpoint}/network-code/$networkCodeId?status=pending');
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get network join requests failed: $e');
      return [];
    }
  }

  /// Approve a network join request
  Future<void> approveNetworkJoinRequest(String requestId) async {
    if (ApiConfig.useMockAuth) return;

    try {
      final body = {'status': 'accepted'};
      await _apiClient.put('${ApiConfig.connectionsEndpoint}/$requestId/status', body: body);
      print('✅ Approved network join request: $requestId');
    } catch (e) {
      print('❌ Approve network join request failed: $e');
      rethrow;
    }
  }

  // ============================================================================
  // FOLLOWING MANAGEMENT
  // ============================================================================

  /// Follow a profile
  Future<Map<String, dynamic>> followProfile({
    required String userId,
    required String followingId, // The ID of the user being followed
    String? label,
    String? type,
    String? role,
    List<String> tags = const [],
  }) async {
    if (ApiConfig.useMockAuth) {
      return {'message': 'Followed mock user'};
    }

    try {
      final response = await _apiClient.post('${ApiConfig.followingsEndpoint}/follow/$followingId');
      print('✅ Followed user: $followingId');
      return response;
    } catch (e) {
      print('❌ Follow profile failed: $e');
      rethrow;
    }
  }

  /// Unfollow a profile
  Future<void> unfollowProfile(String userId, String followingId) async {
    if (ApiConfig.useMockAuth) return;

    try {
      await _apiClient.delete('${ApiConfig.followingsEndpoint}/unfollow/$followingId');
      print('✅ Unfollowed user: $followingId');
    } catch (e) {
      print('❌ Unfollow profile failed: $e');
      rethrow;
    }
  }

  /// Get user's followings
  Future<List<Map<String, dynamic>>> getUserFollowings(String userId) async {
    if (ApiConfig.useMockAuth) {
      return [];
    }

    try {
      final response = await _apiClient.get(ApiConfig.followingsEndpoint);
      
      // Handle wrapped response
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get user followings failed: $e');
      return [];
    }
  }

  // ============================================================================
  // EVENT MANAGEMENT
  // ============================================================================

  // ============================================================================
  // EVENT MANAGEMENT
  // ============================================================================

  /// Create a new event
  Future<Map<String, dynamic>> createEvent({
    required String name,
    String? headline,
    required String description,
    required DateTime dateTime,
    required String location,
    List<String> photos = const [],
    List<String> videos = const [],
    List<String> tags = const [],
    String? createdBy,
  }) async {
    if (ApiConfig.useMockAuth) {
      return {
        'id': 'mock_event_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'headline': headline,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'location': location,
        'photos': photos,
        'videos': videos,
        'tags': tags,
        'createdBy': createdBy ?? 'mock_user',
      };
    }

    try {
      final body = {
        'name': name,
        'headline': headline,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'location': location,
        'photos': photos,
        'videos': videos,
        'tags': tags,
      };

      final response = await _apiClient.post('/events', body: body);
      
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        print('✅ Created event: ${response['data']['_id']}');
        return response['data'];
      }
      
      return response;
    } catch (e) {
      print('❌ Create event failed: $e');
      rethrow;
    }
  }

  /// Update an existing event
  Future<Map<String, dynamic>> updateEvent({
    required String eventId,
    String? name,
    String? headline,
    String? description,
    DateTime? dateTime,
    String? location,
    List<String>? photos,
    List<String>? videos,
    List<String>? tags,
  }) async {
    if (ApiConfig.useMockAuth) {
      return {
        'id': eventId,
        'name': name ?? 'Updated Event',
      };
    }

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (headline != null) body['headline'] = headline;
      if (description != null) body['description'] = description;
      if (dateTime != null) body['dateTime'] = dateTime.toIso8601String();
      if (location != null) body['location'] = location;
      if (photos != null) body['photos'] = photos;
      if (videos != null) body['videos'] = videos;
      if (tags != null) body['tags'] = tags;

      final response = await _apiClient.put('/events/$eventId', body: body);
      
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        print('✅ Updated event: $eventId');
        return response['data'];
      }
      
      return response;
    } catch (e) {
      print('❌ Update event failed: $e');
      rethrow;
    }
  }

  /// Join an event (Event Connections)
  Future<Map<String, dynamic>> joinEvent({
    required String eventId,
    required String participantId,
  }) async {
    if (ApiConfig.useMockAuth) {
      return {'success': true, 'message': 'Joined mock event'};
    }

    try {
      final body = {
        'eventId': eventId,
        'participantId': participantId,
      };

      final response = await _apiClient.post('/event-connections/join', body: body);
      print('✅ Joined event: $eventId');
      return response;
    } catch (e) {
      print('❌ Join event failed: $e');
      rethrow;
    }
  }



  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    if (ApiConfig.useMockAuth) return;

    try {
      await _apiClient.delete('/events/$eventId');
      print('✅ Deleted event: $eventId');
    } catch (e) {
      print('❌ Delete event failed: $e');
      rethrow;
    }
  }

  /// Get all events
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    if (ApiConfig.useMockAuth) {
      return [
        {
          'id': 'mock_event_1',
          'name': 'Mock Tech Meetup',
          'headline': 'Join us for tech talk',
          'description': 'A gathering of tech enthusiasts.',
          'dateTime': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          'location': 'Virtual',
          'photos': [],
          'tags': ['Tech', 'Networking'],
          'createdBy': {'name': 'Mock Organizer'},
        }
      ];
    }

    try {
      print('📥 Fetching all events from backend...');
      final response = await _apiClient.get('/events');
      print('📦 Events response type: ${response.runtimeType}');
      
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          print('✅ Got ${data.length} events from wrapped response');
          if (data.isNotEmpty) {
            print('   First event keys: ${data[0].keys.toList()}');
            print('   First event _id: ${data[0]['_id']}');
            print('   First event id: ${data[0]['id']}');
          }
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      if (response is List) {
        print('✅ Got ${response.length} events from direct list');
        if (response.isNotEmpty) {
          print('   First event keys: ${response[0].keys.toList()}');
          print('   First event _id: ${response[0]['_id']}');
          print('   First event id: ${response[0]['id']}');
        }
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('❌ Get all events failed: $e');
      return [];
    }
  }

  /// Get event by ID
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    if (ApiConfig.useMockAuth) {
      return {
        'id': eventId,
        'name': 'Mock Event',
        'description': 'Mock description',
        'dateTime': DateTime.now().toIso8601String(),
        'location': 'Mock Location',
      };
    }

    try {
      final response = await _apiClient.get('/events/$eventId');
      
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'];
      }
      
      return response;
    } catch (e) {
      print('❌ Get event failed: $e');
      return null;
    }
  }

  /// Convert file to Base64 Data URL (replaces uploadMedia)
  Future<String> uploadMedia(File file) async {
    if (ApiConfig.useMockAuth) {
      return 'https://via.placeholder.com/150';
    }

    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Determine mime type (simple guess based on extension)
      String mimeType = 'image/jpeg';
      final path = file.path.toLowerCase();
      if (path.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (path.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (path.endsWith('.webp')) {
        mimeType = 'image/webp';
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      print('❌ Convert media to Base64 failed: $e');
      rethrow;
    }
  }
}
