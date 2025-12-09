import '../models/goal.dart';
import '../models/user.dart';
import '../models/connection.dart';
import '../models/assistant_activity.dart';

class MockDataService {
  // Mock current user - returns null (no user)
  static User? getCurrentUser() {
    return null;
  }

  // Mock active goal - returns null (no active goal)
  static Goal? getActiveGoal({bool hasGoal = false}) {
    return null;
  }

  // Mock assistant activities - returns empty list
  static List<AssistantActivity> getAssistantActivities() {
    return [];
  }

  // Mock inner circle connections - returns empty list
  static List<Connection> getInnerCircle() {
    return [];
  }
}
