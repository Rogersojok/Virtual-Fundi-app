import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// **Initialize Notifications**
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  /// **Show Syncing Notification**
  static Future<void> showSyncingNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'sync_channel',
      'Data Syncing',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Keeps the notification persistent
      showProgress: true,
      maxProgress: 100,
      onlyAlertOnce: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Syncing Data...',
      'Please wait while data is being synced',
      details,
    );
  }

  /// **Update Progress (Optional)**
  static Future<void> updateProgress(int progress) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'sync_channel',
      'Data Syncing',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showProgress: true,
      maxProgress: 100,
      onlyAlertOnce: true,
    );

    final NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Syncing Data...',
      'Progress: $progress%',
      details,
    );
  }

  /// **Remove Notification After Sync**
  static Future<void> removeNotification() async {
    await _notificationsPlugin.cancel(0); // Remove the notification
  }
}
