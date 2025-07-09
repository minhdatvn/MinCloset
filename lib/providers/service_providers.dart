// lib/providers/service_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/services/quest_service.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  // <<< THAY ĐỔI: Đọc key ở đây và truyền vào service >>>
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? 'API_KEY_NOT_FOUND';
  return WeatherService(apiKey: apiKey);
});

// Tương tự, provider này cung cấp một đối tượng của SuggestionService.
final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService();
});

// Provider để tạo và cung cấp navigatorKey duy nhất cho ứng dụng
final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

// Provider để cung cấp NotificationService
final notificationServiceProvider = Provider((ref) {
  // Lấy navigatorKey từ provider ở trên
  final navigatorKey = ref.watch(navigatorKeyProvider);
  // Tạo và trả về một instance của NotificationService
  return NotificationService(navigatorKey);
});

final weatherImageServiceProvider = FutureProvider<WeatherImageService>((ref) async {
  final service = WeatherImageService();
  await service.init(); // Chờ cho service khởi tạo xong
  return service;
});

final numberFormattingServiceProvider = Provider<NumberFormattingService>((ref) {
  return NumberFormattingService();
});

// <<< PROVIDER CHO QUEST SERVICE >>>
final questServiceProvider = Provider<QuestService>((ref) {
  // QuestService cần SharedPreferences, chúng ta sẽ lấy nó từ một provider khác
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    // Trường hợp SharedPreferences chưa sẵn sàng, có thể throw lỗi hoặc trả về một giá trị mặc định
    // Ở đây, chúng ta sẽ throw lỗi để đảm bảo không có lỗi logic không mong muốn
    throw Exception("SharedPreferences not initialized for QuestService");
  }
  return QuestService(prefs);
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});