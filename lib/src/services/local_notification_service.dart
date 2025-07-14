// lib/src/services/local_notification_service.dart

import 'dart:math'; // Thêm import để sử dụng hàm ngẫu nhiên
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Danh sách các nội dung thông báo ngẫu nhiên
  final List<Map<String, String>> _randomMessages = [
    {
      "title": "Your Closet is Calling! ✨",
      "body": "What amazing outfit did you wear today? Let's log it in your journal!"
    },
    {
      "title": "Daily Style Recap 📔",
      "body": "One small step every day. Take a moment to update your fashion journal."
    },
    {
      "title": "Ready for Tomorrow? 👔",
      "body": "A great day starts with a great outfit. Get inspired for tomorrow's look!"
    },
    {
      "title": "MinCloset Misses You! 👋",
      "body": "Don't forget to show your closet some love. What new items have you discovered?"
    }
    // Bạn có thể thêm nhiều cặp title/body khác vào đây
  ];


  Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _configureLocalTimezone();

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
  
  Future<void> requestPermissions() async {
    final iOSImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iOSImplementation != null) {
          await iOSImplementation.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
          );
      }

    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
    }
  }
  
  /// Lên lịch cho một thông báo hàng ngày với nội dung và thời gian ngẫu nhiên.
  Future<void> scheduleDailyReminder() async {
    // 1. Chọn ngẫu nhiên một tin nhắn
    final random = Random();
    final message = _randomMessages[random.nextInt(_randomMessages.length)];
    final title = message['title']!;
    final body = message['body']!;

    // 2. Chọn ngẫu nhiên thời gian từ 19:00 đến 21:00
    final hour = 19 + random.nextInt(3); // 19, 20, 21
    final minute = random.nextInt(60);   // 0-59

    await _notificationsPlugin.zonedSchedule(
      0, // Luôn dùng ID = 0 vì chúng ta chỉ có 1 thông báo định kỳ
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel', // ID kênh mới
          'Daily Reminder',
          channelDescription: 'A daily reminder to engage with your closet.',
          importance: Importance.defaultImportance, // Giảm mức độ quan trọng để ít làm phiền hơn
          priority: Priority.defaultPriority,
        ),
      ),
      // Giúp Android lên lịch chính xác hơn sau khi thiết bị khởi động lại
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      // Chỉ khớp với thời gian, thông báo sẽ lặp lại mỗi ngày vào giờ này
      matchDateTimeComponents: DateTimeComponents.time, 
    );
  }

  // Hàm _nextInstanceOfTime không thay đổi
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
        'instant_test_channel', 
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