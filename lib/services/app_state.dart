import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/user.dart';
import '../models/connection.dart';
import '../models/assistant_activity.dart';
import '../models/network_code.dart';
import '../models/following.dart';
import '../models/qr_profile.dart';
import '../models/tagged_person.dart' as tagged;
import '../services/mock_data_service.dart';
import '../services/auth_service.dart';
import '../services/networking_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  User? _currentUser;
  Goal? _activeGoal; // Start with no active goal
  List<AssistantActivity> _activities = [];
  List<Connection> _innerCircle = [];
  bool _isScannerMode = false;

  // Networking mode state
  bool _isNetworkingMode = false;
  List<NetworkCode> _networkCodes = [];
  NetworkCode? _selectedNetworkCode;
  
  final _secureStorage = const FlutterSecureStorage();
  static const String _networkModeKey = 'network_mode_active';
  static const String _selectedCodeKey = 'selected_network_code';

  AppState() {
    _initUser();
    _restoreNetworkModeState();
  }

  Future<void> refreshUser() async {
    print('🔄 AppState: Refreshing user data...');
    await _initUser();
  }

  Future<void> _initUser() async {
    // ... same as before
    final authUser = await AuthService().fetchUserProfile().catchError((e) {
         print("Error fetching profile on init: $e");
         return AuthService().currentUser; 
    }); 
    // Wait, AuthService().currentUser is a getter. _initUser uses it.
    // But we should try to FETCH fresh data.
    // AuthService has `fetchUserProfile`.
    
    if (authUser != null) {
      _currentUser = User.fromMap(authUser);
      print('✅ AppState: User loaded: ${_currentUser?.name}, Phone: ${_currentUser?.phoneNumber}'); // DEBUG
      await loadNetworkCodes();
      await _loadConnections();
      await _loadFollowings();
    }
    notifyListeners();
  }

  /// Update the current user (e.g. after login)
  void setUser(User user) {
    _currentUser = user;
    // Trigger data loading
    loadNetworkCodes();
    _loadConnections();
    _loadFollowings();
    notifyListeners();
  }

  Future<void> loadNetworkCodes() async {
    if (_currentUser == null) return;
    
    try {
      final codesData = await NetworkingService().getUserNetworkCodes(_currentUser!.id);
      _networkCodes = codesData.map((data) => NetworkCode.fromJson(data)).toList();
      
      // Sort by createdAt descending (most recent first)
      _networkCodes.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1; // nulls go to the end
        if (b.createdAt == null) return -1; // nulls go to the end
        return b.createdAt!.compareTo(a.createdAt!); // descending order
      });
      
      // Select first code if none selected
      if (_networkCodes.isNotEmpty && _selectedNetworkCode == null) {
        _selectedNetworkCode = _networkCodes.first;
      } else if (_networkCodes.isEmpty) {
        _selectedNetworkCode = null;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading network codes: $e');
    }
  }

  // Following state
  UserFollowState _followState = UserFollowState(followings: []);

  // Tagged connections and followings from Network Code scans
  final List<tagged.Connection> _taggedConnections = [];
  final List<tagged.FollowingPerson> _taggedFollowings = [];

  // Getters
  User? get currentUser => _currentUser;
  Goal? get activeGoal => _activeGoal;
  bool get hasActiveGoal => _activeGoal != null;
  List<AssistantActivity> get activities => _activities;
  List<Connection> get innerCircle => _innerCircle;
  bool get isScannerMode => _isScannerMode;
  bool get isNetworkingMode => _isNetworkingMode;
  List<NetworkCode> get networkCodes => _networkCodes;
  NetworkCode? get selectedNetworkCode =>
      _selectedNetworkCode ??
      (_networkCodes.isNotEmpty ? _networkCodes[0] : null);
  UserFollowState get followState => _followState;
  List<tagged.Connection> get taggedConnections => _taggedConnections;
  List<tagged.FollowingPerson> get taggedFollowings => _taggedFollowings;

  // Initialize mock Network Codes - returns empty list
  static List<NetworkCode> _initMockNetworkCodes() {
    return [];
  }

  // Toggle scanner mode
  void toggleScannerMode() {
    _isScannerMode = !_isScannerMode;
    notifyListeners();
  }

  // Set scanner mode explicitly
  void setScannerMode(bool value) {
    _isScannerMode = value;
    notifyListeners();
  }

  // Networking mode methods
  void toggleNetworkingMode() {
    _isNetworkingMode = !_isNetworkingMode;
    notifyListeners();
  }

  Future<void> setNetworkingMode(bool value) async {
    _isNetworkingMode = value;
    
    // Save to storage
    await _secureStorage.write(
      key: _networkModeKey, 
      value: value.toString(),
    );
    
    notifyListeners();
  }

  void selectNetworkCode(NetworkCode code) async {
    _selectedNetworkCode = code;
    
    // Save to storage
    await _secureStorage.write(
      key: _selectedCodeKey,
      value: jsonEncode(code.toJson()),
    );
    
    notifyListeners();
  }

  /// Restore Network Mode state from secure storage
  Future<void> _restoreNetworkModeState() async {
    print('🟣 RESTORING NETWORK MODE STATE...');
    try {
      // Restore networking mode toggle
      final modeString = await _secureStorage.read(key: _networkModeKey);
      if (modeString != null) {
        _isNetworkingMode = modeString == 'true';
        print('  - Network Mode: $_isNetworkingMode');
      }
      
      // Restore selected network code
      final codeJson = await _secureStorage.read(key: _selectedCodeKey);
      if (codeJson != null) {
        try {
          final codeMap = jsonDecode(codeJson) as Map<String, dynamic>;
          _selectedNetworkCode = NetworkCode.fromJson(codeMap);
          print('  - Selected Code: ${_selectedNetworkCode?.codeId}');
        } catch (e) {
          print('  - Error restoring selected network code: $e');
        }
      }
      
      print('✅ NETWORK MODE STATE RESTORED');
      notifyListeners();
    } catch (e) {
      print('❌ Error restoring network mode state: $e');
    }
  }

  void addNetworkCode(NetworkCode code) {
    // Insert at the beginning to maintain sorted order (most recent first)
    _networkCodes.insert(0, code);
    _selectedNetworkCode = code;
    notifyListeners();
  }

  /// Update current user profile
  Future<void> updateCurrentUser(Map<String, dynamic> updates) async {
    if (_currentUser == null) return;
    
    try {
      final updatedUser = await AuthService().updateUserProfile(updates);
      print('🔍 AppState received updated user: $updatedUser'); // DEBUG LOG
      _currentUser = User.fromMap(updatedUser);
      print('🔍 AppState mapped user: ${_currentUser?.company}, ${_currentUser?.location}'); // DEBUG LOG
      notifyListeners();
      print('✅ AppState: User profile updated');
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Clear user data on logout
  void clearUser() {
    _currentUser = null;
    _activeGoal = null;
    _activities = [];
    _innerCircle = [];
    _networkCodes = [];
    _selectedNetworkCode = null;
    _followState = UserFollowState(followings: []);
    _taggedConnections.clear();
    _taggedFollowings.clear();
    notifyListeners();
    print('✅ AppState: User data cleared');
  }

  /// Refresh network codes from database
  Future<void> refreshNetworkCodes() async {
    await loadNetworkCodes();
  }

  /// Add QR profile (creates in backend)
  Future<void> addQrProfile(QrProfile profile) async {
    if (_currentUser == null) return;
    
    try {
      await NetworkingService().createQRProfile(
        userId: _currentUser!.id,
        title: profile.name,
        description: profile.description,
        context: profile.keywords.take(3).join(', '),
        customMessage: '',
      );
      print('✅ QR Profile created successfully');
    } catch (e) {
      print('❌ Error creating QR profile: $e');
      rethrow;
    }
  }


  // Create a new goal
  void createGoal(Goal goal) {
    _activeGoal = goal;
    _activities = MockDataService.getAssistantActivities();
    notifyListeners();
  }

  // For testing: toggle having an active goal
  void toggleActiveGoal() {
    if (_activeGoal != null) {
      _activeGoal = null;
    } else {
      _activeGoal = MockDataService.getActiveGoal(hasGoal: true);
      _activities = MockDataService.getAssistantActivities();
    }
    notifyListeners();
  }

  // Following methods
  Future<void> followProfile(Following following) async {
    if (_currentUser == null) return;
    
    try {
      await NetworkingService().followProfile(
        userId: _currentUser!.id,
        followingId: following.id, // This might need to be the real ID if 'following.id' is just a placeholder
        label: following.label,
        type: following.type,
        role: following.role,
        tags: following.tags,
      );
      
      _followState = _followState.follow(following);
      notifyListeners();
    } catch (e) {
      print('Error following profile: $e');
    }
  }

  Future<void> unfollowProfile(String followingId) async {
    if (_currentUser == null) return;

    try {
      // We need to find the following object to get the real ID if needed, 
      // but here we assume followingId is the one stored in DB.
      // However, NetworkingService.unfollowProfile needs userId and followingId.
      // Wait, NetworkingService.unfollowProfile takes (userId, followingId).
      // But 'followingId' in NetworkingService is the ID of the target, not the 'follow_xxx' ID.
      // The 'followingId' passed to this method is likely the ID of the target (e.g. user ID or circle ID).
      
      await NetworkingService().unfollowProfile(_currentUser!.id, followingId);
      
      _followState = _followState.unfollow(followingId);
      notifyListeners();
    } catch (e) {
      print('Error unfollowing profile: $e');
    }
  }

  bool isFollowing(String followingId) {
    return _followState.isFollowing(followingId);
  }

  // Get target profiles for goal execution (placeholder/mock)
  List<String> getTargetProfilesForGoal(Goal goal) {
    switch (goal.runScope) {
      case GoalRunScope.allNetwork:
        // Return empty list as marker for "all network"
        return [];
      case GoalRunScope.followingsOnly:
        // Return all following IDs
        return _followState.followings.map((f) => f.id).toList();
      case GoalRunScope.selectedCircles:
        // Return only selected following IDs
        return goal.selectedFollowingIds;
    }
  }

  // Add tagged connection from scan
  void addTaggedConnection(tagged.Connection connection) {
    _taggedConnections.add(connection);
    notifyListeners();
  }

  // Add tagged following from scan
  void addTaggedFollowing(tagged.FollowingPerson following) {
    _taggedFollowings.add(following);
    notifyListeners();
  }

  // Get network code label by id
  String getNetworkCodeLabel(String networkCodeId) {
    final code = _networkCodes.firstWhere(
      (nc) => nc.id == networkCodeId,
      orElse: () => NetworkCode(
        id: '',
        name: 'Unknown',
        codeId: '',
        description: '',
        keywords: [],
      ),
    );
    return code.name;
  }

  Future<void> _loadConnections() async {
    if (_currentUser == null) return;

    try {
      final connectionsData = await NetworkingService().getUserConnections(_currentUser!.id);
      final List<Connection> loadedConnections = [];

      for (final data in connectionsData) {
        // Determine the other user ID
        // Handle both backend schema (requestorId/userId) and legacy mock schema (userId1/userId2)
        String? requestorId;
        String? ownerId;
        
        if (data.containsKey('requestorId')) {
          requestorId = data['requestorId'] is Map ? data['requestorId']['_id'] : data['requestorId'];
        } else {
          requestorId = data['userId1'];
        }
        
        if (data.containsKey('userId')) {
          ownerId = data['userId'] is Map ? data['userId']['_id'] : data['userId'];
        } else {
          ownerId = data['userId2'];
        }
        
        final otherUserId = (requestorId == _currentUser!.id) ? ownerId : requestorId;
        
        if (otherUserId == null) {
          print('⚠️ Skipping connection with null user ID: $data');
          continue;
        }
        
        // Fetch user details
        final userMap = await NetworkingService().getUser(otherUserId);
        
        // Handle Date parsing safely
        DateTime connectedAt;
        if (data['connectedAt'] != null) {
          connectedAt = DateTime.parse(data['connectedAt']);
        } else if (data['createdAt'] != null) {
          connectedAt = DateTime.parse(data['createdAt']);
        } else {
          connectedAt = DateTime.now();
        }

        if (userMap != null) {
          loadedConnections.add(Connection(
            id: data['_id'] ?? data['id'] ?? '',
            userId: otherUserId,
            name: userMap['name'] ?? 'Unknown',
            role: userMap['role'] ?? 'Member',
            company: userMap['company'],
            avatarUrl: userMap['avatarUrl'] ?? userMap['photoUrl'],
            connectedAt: connectedAt,
            type: ConnectionType.innerCircle, // Defaulting to innerCircle for now
            sharedInterests: List<String>.from(data['tags'] ?? []),
          ));
        }
      }

      _innerCircle = loadedConnections;
      notifyListeners();
    } catch (e) {
      print('Error loading connections: $e');
    }
  }

  Future<void> _loadFollowings() async {
    if (_currentUser == null) return;

    try {
      final followingsData = await NetworkingService().getUserFollowings(_currentUser!.id);
      final List<Following> loadedFollowings = followingsData.map((data) {
        return Following(
          id: data['followingId'], // Use the target ID as the ID for checking 'isFollowing'
          label: data['label'],
          type: data['type'],
          role: data['role'],
          tags: List<String>.from(data['tags'] ?? []),
        );
      }).toList();

      _followState = UserFollowState(followings: loadedFollowings);
      notifyListeners();
    } catch (e) {
      print('Error loading followings: $e');
    }
  }
}
