import '../../models/goal.dart';
import '../../models/user.dart';
import '../../models/connection.dart';
import '../../models/assistant_activity.dart';

class MockDataService {
  // Mock current user
  static User getCurrentUser() {
    return User(
      id: 'user_001',
      name: 'Alex Johnson',
      email: 'alex@techventure.ai',
      role: 'Founder & CEO',
      company: 'TechVenture AI',
      bio:
          'Building the future of AI-powered networking. Previously scaled 2 startups to acquisition.',
      interests: ['AI/ML', 'SaaS', 'B2B', 'Fundraising'],
    );
  }

  // Mock active goal (null = no active goal)
  static Goal? getActiveGoal({bool hasGoal = true}) {
    if (!hasGoal) return null;

    return Goal(
      id: 'goal_001',
      title: 'Raising Pre-Seed for AI SaaS',
      description:
          'Looking to connect with angel investors and early-stage VCs interested in AI/ML SaaS products. Target: \$500K-\$1M.',
      tags: ['Fundraising', 'Pre-Seed', 'AI', 'SaaS'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 25)),
      status: GoalStatus.active,
      progress: 35,
    );
  }

  // Mock assistant activities
  static List<AssistantActivity> getAssistantActivities() {
    return [
      AssistantActivity(
        id: 'activity_001',
        title: 'Found 3 potential investors',
        description:
            'Matched your goal with 3 angel investors interested in AI SaaS',
        type: ActivityType.connectionSuggestion,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: ActivityStatus.completed,
      ),
      AssistantActivity(
        id: 'activity_002',
        title: 'Goal progress update',
        description: 'You\'ve connected with 2 out of 5 target investors',
        type: ActivityType.goalProgress,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        status: ActivityStatus.completed,
      ),
      AssistantActivity(
        id: 'activity_003',
        title: 'Researching market trends',
        description: 'Analyzing current AI SaaS funding landscape',
        type: ActivityType.research,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: ActivityStatus.inProgress,
      ),
      AssistantActivity(
        id: 'activity_004',
        title: 'Upcoming event match',
        description: 'TechCrunch Disrupt has 12 relevant investors attending',
        type: ActivityType.insight,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: ActivityStatus.completed,
      ),
      AssistantActivity(
        id: 'activity_005',
        title: 'Follow-up reminder',
        description:
            'Remember to reach out to Sarah Chen from last week\'s connection',
        type: ActivityType.reminder,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        status: ActivityStatus.pending,
      ),
    ];
  }

  // Mock inner circle connections
  static List<Connection> getInnerCircle() {
    return [
      Connection(
        id: 'conn_001',
        userId: 'user_101',
        name: 'Sarah Chen',
        role: 'Angel Investor',
        company: 'Chen Ventures',
        connectedAt: DateTime.now().subtract(const Duration(days: 7)),
        type: ConnectionType.innerCircle,
        sharedInterests: ['AI/ML', 'SaaS'],
      ),
      Connection(
        id: 'conn_002',
        userId: 'user_102',
        name: 'Michael Rodriguez',
        role: 'Co-Founder',
        company: 'DataFlow AI',
        connectedAt: DateTime.now().subtract(const Duration(days: 14)),
        type: ConnectionType.innerCircle,
        sharedInterests: ['AI/ML', 'B2B', 'SaaS'],
      ),
      Connection(
        id: 'conn_003',
        userId: 'user_103',
        name: 'Emily Watson',
        role: 'Partner',
        company: 'Venture Capital Partners',
        connectedAt: DateTime.now().subtract(const Duration(days: 21)),
        type: ConnectionType.innerCircle,
        sharedInterests: ['Fundraising', 'SaaS'],
      ),
      Connection(
        id: 'conn_004',
        userId: 'user_104',
        name: 'David Kim',
        role: 'Tech Lead',
        company: 'AI Innovations',
        connectedAt: DateTime.now().subtract(const Duration(days: 30)),
        type: ConnectionType.innerCircle,
        sharedInterests: ['AI/ML'],
      ),
    ];
  }
}
