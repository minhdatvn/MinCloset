// lib/notifiers/item_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/repository_providers.dart'; // <<< THAY ĐỔI IMPORT
import 'package:mincloset/repositories/clothing_item_repository.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/utils/logger.dart';

class ItemDetailNotifier extends StateNotifier<ClothingItem> {
  // <<< THAY ĐỔI: Phụ thuộc vào Repository thay vì DbHelper
  final ClothingItemRepository _clothingItemRepo;

  ItemDetailNotifier(this._clothingItemRepo, ClothingItem initialItem) : super(initialItem);

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    await updateField(name: newName.trim());
  }

  Future<void> updateField({
    String? name,
    Set<String>? color,
    Set<String>? season,
    Set<String>? occasion,
    Set<String>? material,
    Set<String>? pattern,
  }) async {
    final updatedItem = state.copyWith(
      name: name,
      color: color?.join(', '),
      season: season?.join(', '),
      occasion: occasion?.join(', '),
      material: material?.join(', '),
      pattern: pattern?.join(', '),
    );

    try {
      // <<< THAY ĐỔI: Gọi đến Repository
      await _clothingItemRepo.updateItem(updatedItem);
      state = updatedItem;
    } catch (e, s) {
      logger.e("Lỗi khi cập nhật item", error: e, stackTrace: s);
    }
  }

  Future<void> deleteItem() async {
    // <<< THAY ĐỔI: Gọi đến Repository
    await _clothingItemRepo.deleteItem(state.id);
  }
}

final itemDetailProvider = StateNotifierProvider.autoDispose
    .family<ItemDetailNotifier, ClothingItem, ClothingItem>((ref, initialItem) {
  // <<< THAY ĐỔI: Inject ClothingItemRepository
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  return ItemDetailNotifier(clothingItemRepo, initialItem);
});