// lib/src/services/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Khởi tạo cài đặt cho các nền tảng
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    // Sửa lỗi: Xóa tham số onDidReceiveLocalNotification không còn tồn tại
    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    // 2. Cấu hình múi giờ
    await _configureLocalTimezone();

    // 3. Khởi tạo plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // 4. Yêu cầu quyền trên Android
    await _requestAndroidPermission();
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    // Sửa lỗi: Sử dụng đúng tên class FlutterTimezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
  
  Future<void> _requestAndroidPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
        // Yêu cầu đồng thời 2 quyền cần thiết cho các phiên bản Android mới
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleMorningReminder() async {
    await _notificationsPlugin.zonedSchedule(
      0, 
      "Good Morning! ☀️",
      "The weather is nice today! What will you wear to shine? Let's plan it!",
      _nextInstanceOfTime(7, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_reminder_channel',
          'Morning Reminder',
          channelDescription: 'Reminds user to plan their outfit for the day.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Sửa lỗi: Xóa tham số uiLocalNotificationDateInterpretation không còn tồn tại
      matchDateTimeComponents: DateTimeComponents.time, 
    );
  }

  Future<void> scheduleEveningReminder() async {
    await _notificationsPlugin.zonedSchedule(
      1, 
      "Daily Mission! ✨",
      "One small step every day. Don't forget to update your fashion journal!",
      _nextInstanceOfTime(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'evening_reminder_channel',
          'Evening Reminder',
          channelDescription: 'Reminds user to log their outfit of the day.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Sửa lỗi: Xóa tham số uiLocalNotificationDateInterpretation không còn tồn tại
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> showNow(int id, String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_test_channel', // Một channel ID khác cho việc test
        'Instant Test Notifications',
        channelDescription: 'For immediate testing of notifications.',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _notificationsPlugin.show(id, title, body, platformChannelSpecifics);
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}