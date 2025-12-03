import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(initSettings);

    // Android 13+ needs runtime permission
    final androidImpl =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> showReminder(Task task) async {
    const androidDetails = AndroidNotificationDetails(
      'geo_remind_channel', // channel ID
      'GeoRemind notifications', // channel name
      channelDescription: 'Reminders when you are near saved locations',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      task.id ?? task.hashCode,
      'Geo reminder: ${task.title}',
      task.description ?? 'You are near your reminder location.',
      details,
    );
  }
}
