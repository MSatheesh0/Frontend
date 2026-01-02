import '../models/app_notification.dart';
import 'api_client.dart';

class AppNotificationService {
  static final AppNotificationService _instance = AppNotificationService._internal();
  factory AppNotificationService() => _instance;
  AppNotificationService._internal();

  final _apiClient = ApiClient();

  Future<List<AppNotification>> getNotifications() async {
     try {
       final response = await _apiClient.get('/notifications');
       if (response is Map && response['data'] != null) {
          return (response['data'] as List)
              .map((json) => AppNotification.fromJson(json))
              .toList();
       }
       return [];
     } catch (e) {
       print('Error fetching notifications: $e');
       return [];
     }
  }

  Future<void> dismissNotification(String id) async {
    try {
      await _apiClient.patch('/notifications/$id/dismiss', body: {});
    } catch (e) {
      print('Error dismissing notification: $e');
    }
  }
}
