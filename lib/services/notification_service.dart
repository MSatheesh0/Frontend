
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'networking_qr_channel_v2'; // Updated channel ID for new settings
  static const String _channelName = 'Networking QR Code';
  static const String _channelDescription =
      'Shows your QR code when Networking Mode is active';

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max, // MAX importance for full screen intent
      playSound: false,
      enableVibration: true,
    );
     // Note: for older flutter_local_notifications versions, createNotificationChannel might need 'resolvePlatformSpecificImplementation'.
     // For version 17+, it works like this:
     await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

  }

  /// Downloads QR image and shows notification
  Future<void> showPersistentQrNotification({
    required String title, 
    required String body, 
    required String codeId
  }) async {
    try {
      // 1. Download image - increased size for better visibility
      final String imageUrl = 'https://quickchart.io/qr?text=${Uri.encodeComponent(codeId)}&size=600&margin=2';
      final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'qr_image.png');

      // 2. Configure Notification style - optimized for large image
      final BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        contentTitle: title,
        summaryText: body,
        hideExpandedLargeIcon: true, // Hides the small icon when expanded to show full picture
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      );

      // 3. Notification Details
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max, // Max importance for heads-up
        priority: Priority.max, // Max priority
        ongoing: true, // Make it persistent (cannot be dismissed)
        autoCancel: false,
        styleInformation: bigPictureStyleInformation,
        largeIcon: FilePathAndroidBitmap(largeIconPath), // Show QR as large icon too
        visibility: NotificationVisibility.public, // Show on lock screen
        fullScreenIntent: true, // Allow full screen intent
        category: AndroidNotificationCategory.call, // Treat as incoming call for high priority
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        888, // Fixed ID for the networking notification
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Error showing QR notification: $e');
    }
  }

  Future<void> cancelQrNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(888);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
