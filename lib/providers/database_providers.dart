// lib/providers/database_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';

final dbHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final closetsProvider = FutureProvider<List<Closet>>((ref) {
  final closetRepository = ref.watch(closetRepositoryProvider);
  return closetRepository.getClosets();
});

// <<< THAY ĐỔI Ở ĐÂY
final itemsInClosetProvider =
    FutureProvider.family<List<ClothingItem>, String>((ref, closetId) {
  ref.watch(itemAddedTriggerProvider);
  final clothingItemRepository = ref.watch(clothingItemRepositoryProvider);
  return clothingItemRepository.getItemsInCloset(closetId);
});