// lib/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/city_repository.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/settings_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/wear_log_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final closetRepositoryProvider = Provider<ClosetRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ClosetRepository(dbHelper);
});

final clothingItemRepositoryProvider = Provider<ClothingItemRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ClothingItemRepository(dbHelper);
});

final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return OutfitRepository(dbHelper);
});

// <<< SỬA LẠI Ở ĐÂY >>>
// Sử dụng `weatherServiceProvider` để đảm bảo tính nhất quán
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherRepository(weatherService);
});

final suggestionRepositoryProvider = Provider<SuggestionRepository>((ref) {
  final suggestionService = ref.watch(suggestionServiceProvider);
  return SuggestionRepository(suggestionService);
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  // Tương tự, cũng sử dụng `weatherServiceProvider`
  final weatherService = ref.watch(weatherServiceProvider);
  return CityRepository(weatherService);
});

final wearLogRepositoryProvider = Provider<WearLogRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return WearLogRepository(dbHelper);
});

// Provider này sẽ cung cấp instance của SharedPreferences một cách bất đồng bộ.
// Các provider khác có thể "watch" provider này để đảm bảo SharedPreferences đã sẵn sàng trước khi sử dụng.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// Provider để cung cấp SettingsRepository cho toàn bộ ứng dụng.
// Nó phụ thuộc vào sharedPreferencesProvider.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref); // Chỉ cần truyền ref vào
});