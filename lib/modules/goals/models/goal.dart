enum GoalRunScope {
  allNetwork,
  followingsOnly,
  selectedCircles,
}

class Goal {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime expiresAt;
  final GoalStatus status;
  final int progress; // 0-100
  final GoalRunScope runScope;
  final List<String> selectedFollowingIds;
  final String? contextCircleId; // For event circles

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.progress = 0,
    this.runScope = GoalRunScope.allNetwork,
    this.selectedFollowingIds = const [],
    this.contextCircleId,
  });

  int get daysRemaining {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return 0;
    return expiresAt.difference(now).inDays;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

enum GoalStatus {
  active,
  paused,
  completed,
  expired,
}
