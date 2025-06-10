import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initialize() async {
    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  // Background message handler
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    // Handle background notification here
    print("Handling background message: ${message.messageId}");
    // You can also show a notification here
  }

  void showNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'default_channel', // Channel ID
      'Default', // Channel Name
      channelDescription: 'This is the default channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      notificationDetails,
    );
  }
}
