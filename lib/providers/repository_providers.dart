// lib/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart'; // <<< THÊM IMPORT
import 'package:mincloset/repositories/outfit_repository.dart';       // <<< THÊM IMPORT

final closetRepositoryProvider = Provider<ClosetRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ClosetRepository(dbHelper);
});

// <<< THÊM PROVIDER CHO CLOTHING ITEM REPOSITORY
final clothingItemRepositoryProvider = Provider<ClothingItemRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ClothingItemRepository(dbHelper);
});

// <<< THÊM PROVIDER CHO OUTFIT REPOSITORY
final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return OutfitRepository(dbHelper);
});