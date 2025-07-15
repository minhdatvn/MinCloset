// lib/providers/service_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/services/achievement_service.dart';
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
  // Giờ đây chúng ta có thể đọc trực tiếp và an toàn
  final prefs = ref.watch(sharedPreferencesProvider);
  final achievementRepo = ref.watch(achievementRepositoryProvider);

  // Không cần kiểm tra null nữa
  return QuestService(prefs, achievementRepo, ref);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Provider này sẽ luôn được ghi đè trong main.dart,
  // việc throw lỗi ở đây để đảm bảo chúng ta không quên.
  throw UnimplementedError();
});

final achievementServiceProvider = Provider<AchievementService>((ref) {
  // Tương tự, cập nhật ở đây
  final prefs = ref.watch(sharedPreferencesProvider);
  return AchievementService(prefs);
});

final nestedNavigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());