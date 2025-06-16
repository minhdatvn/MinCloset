// lib/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart'; // <<< THÊM IMPORT
import 'package:mincloset/repositories/outfit_repository.dart';       // <<< THÊM IMPORT
import 'package:mincloset/repositories/suggestion_repository.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/repositories/weather_repository.dart'; 

final closetRepositoryProvider = Provider<ClosetRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ClosetRepository(dbHelper);
});

// PROVIDER CHO CLOTHING ITEM REPOSITORY
final clothingItemRepositoryProvider = Provider<ClothingItemRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ClothingItemRepository(dbHelper);
});

// PROVIDER CHO OUTFIT REPOSITORY
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