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
import 'package:mincloset/repositories/quest_repository.dart';
import 'package:mincloset/repositories/achievement_repository.dart';

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

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherRepository(weatherService);
});

final suggestionRepositoryProvider = Provider<SuggestionRepository>((ref) {
  final suggestionService = ref.watch(suggestionServiceProvider);
  return SuggestionRepository(suggestionService);
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return CityRepository(weatherService);
});

final wearLogRepositoryProvider = Provider<WearLogRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return WearLogRepository(dbHelper);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref);
});

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final questService = ref.watch(questServiceProvider);
  return QuestRepository(questService);
});

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  final service = ref.watch(achievementServiceProvider);
  return AchievementRepository(service);
});