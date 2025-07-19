// lib/providers/service_providers.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/services/quest_service.dart';
import 'package:mincloset/services/remote_config_service.dart';
import 'package:mincloset/services/secure_storage_service.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

export '../services/backup_service.dart';
export '../services/restore_service.dart';

/// Provider này hoạt động như một công tắc BẬT/TẮT toàn cục.
/// Nó cho toàn bộ ứng dụng biết: "API keys đã sẵn sàng để sử dụng chưa?".
/// Mặc định là `false` (chưa sẵn sàng).
final apiKeysReadyProvider = StateProvider<bool>((ref) => false);

// Provider cho SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Provider cho RemoteConfigService
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(
    remoteConfig: FirebaseRemoteConfig.instance,
    secureStorage: ref.watch(secureStorageServiceProvider),
    connectivity: Connectivity(),
    ref: ref, // Sửa lỗi 1: Truyền `ref` vào constructor
  );
});

// Provider đặc biệt để xử lý việc khởi tạo
// Nó sẽ chạy hàm initializeAndFetchKeys và trả về kết quả
final appInitializationProvider = Provider<void>((ref) {
  ref.read(remoteConfigServiceProvider).initializeAndFetchKeys();
});

final weatherServiceProvider = Provider<WeatherService>((ref) {
  // Đọc secure storage service
  final secureStorage = ref.watch(secureStorageServiceProvider);
  // Truyền nó vào constructor của WeatherService
  return WeatherService(secureStorage: secureStorage);
});

// Provider này cung cấp một đối tượng của SuggestionService.
final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return SuggestionService(secureStorage);
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
  final prefs = ref.watch(sharedPreferencesProvider);
  return QuestService(prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Provider này sẽ luôn được ghi đè trong main.dart,
  // việc throw lỗi ở đây để đảm bảo chúng ta không quên.
  throw UnimplementedError();
});

final nestedNavigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());