import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/user.dart';
import '../../models/connection.dart';
import '../../models/assistant_activity.dart';
import '../../models/network_code.dart';
import '../../models/following.dart';
import '../../models/tagged_person.dart' as tagged;
import '../services/mock_data_service.dart';

class AppState extends ChangeNotifier {
  User _currentUser = MockDataService.getCurrentUser();
  Goal? _activeGoal; // Start with no active goal
  List<AssistantActivity> _activities = [];
  List<Connection> _innerCircle = MockDataService.getInnerCircle();
  bool _isScannerMode = false;

  /// Update the current user (e.g. after login)
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Networking mode state
  bool _isNetworkingMode = false;
  List<NetworkCode> _networkCodes = _initMockNetworkCodes();
  NetworkCode? _selectedNetworkCode;

  // Following state
  UserFollowState _followState = UserFollowState.getMockState();

  // Tagged connections and followings from Network Code scans
  final List<tagged.Connection> _taggedConnections = [];
  final List<tagged.FollowingPerson> _taggedFollowings = [];

  // Getters
  User get currentUser => _currentUser;
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

  // Initialize mock Network Codes
  static List<NetworkCode> _initMockNetworkCodes() {
    return [
      NetworkCode(
        id: '1',
        name: 'Events',
        codeId: 'johndev.events',
        description: 'Startup events, professional events',
        keywords: ['Networking', 'Startups', 'Professional'],
        autoConnect: true,
      ),
      NetworkCode(
        id: '2',
        name: 'AI Meetup',
        codeId: 'john.ai',
        description: 'Artificial intelligence and machine learning meetups',
        keywords: ['AI', 'Machine Learning', 'Technology'],
        autoConnect: true,
      ),
      NetworkCode(
        id: '3',
        name: 'Healthcare Circle',
        codeId: 'johnmed.health',
        description: 'Healthcare professionals and medical conferences',
        keywords: ['Healthcare', 'Medical', 'Hospital'],
        autoConnect: false,
      ),
      NetworkCode(
        id: '4',
        name: 'Fintech Circle',
        codeId: 'john-fintech',
        description: 'Financial technology and banking professionals',
        keywords: ['Fintech', 'Banking', 'Finance', 'Technology'],
        autoConnect: false,
      ),
    ];
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

  void setNetworkingMode(bool value) {
    _isNetworkingMode = value;
    notifyListeners();
  }

  void selectNetworkCode(NetworkCode code) {
    _selectedNetworkCode = code;
    notifyListeners();
  }

  void addNetworkCode(NetworkCode code) {
    _networkCodes.add(code);
    _selectedNetworkCode = code;
    notifyListeners();
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
  void followProfile(Following following) {
    _followState = _followState.follow(following);
    notifyListeners();
  }

  void unfollowProfile(String followingId) {
    _followState = _followState.unfollow(followingId);
    notifyListeners();
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
}
