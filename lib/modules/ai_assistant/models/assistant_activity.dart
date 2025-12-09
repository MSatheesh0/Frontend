class AssistantActivity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime timestamp;
  final ActivityStatus status;

  AssistantActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.status,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

enum ActivityType {
  connectionSuggestion,
  goalProgress,
  research,
  reminder,
  insight,
}

enum ActivityStatus {
  pending,
  completed,
  inProgress,
}
