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

// <<< THAY ĐỔI CỐT LÕI NẰM Ở ĐÂY >>>
final closetsProvider = FutureProvider<List<Closet>>((ref) async {
  final closetRepository = ref.watch(closetRepositoryProvider);
  final result = await closetRepository.getClosets();

  // Dùng fold để xử lý kết quả Either
  // Nếu thành công (Right), trả về danh sách closets
  // Nếu thất bại (Left), ném ra lỗi để FutureProvider bắt lại và chuyển sang trạng thái .error
  return result.fold(
    (failure) => throw failure.message,
    (closets) => closets,
  );
});

final itemsInClosetProvider =
    FutureProvider.family<List<ClothingItem>, String>((ref, closetId) async {
  ref.watch(itemChangedTriggerProvider);
  final clothingItemRepository = ref.watch(clothingItemRepositoryProvider);
  final result = await clothingItemRepository.getItemsInCloset(closetId);

  return result.fold(
    (failure) => throw failure.message,
    (items) => items,
  );
});