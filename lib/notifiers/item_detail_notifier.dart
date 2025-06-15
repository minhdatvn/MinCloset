// lib/notifiers/item_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/utils/logger.dart';

class ItemDetailNotifier extends StateNotifier<ClothingItem> {
  final DatabaseHelper _dbHelper;

  ItemDetailNotifier(this._dbHelper, ClothingItem initialItem) : super(initialItem);

  // <<< THÊM PHƯƠNG THỨC MỚI NÀY
  Future<void> updateName(String newName) async {
    // Chỉ cập nhật nếu tên mới không rỗng
    if (newName.trim().isEmpty) return;
    
    // Gọi phương thức `updateField` đã có để tránh lặp code
    // Bằng cách chỉ truyền vào tham số `name`
    await updateField(name: newName.trim());
  }

  // Thêm `String? name` vào phương thức updateField
  Future<void> updateField({
    String? name, // <<< THÊM THAM SỐ NÀY
    Set<String>? color,
    Set<String>? season,
    Set<String>? occasion,
    Set<String>? material,
    Set<String>? pattern,
  }) async {
    final updatedItem = state.copyWith(
      name: name, // <<< THÊM DÒNG NÀY
      color: color?.join(', '),
      season: season?.join(', '),
      occasion: occasion?.join(', '),
      material: material?.join(', '),
      pattern: pattern?.join(', '),
    );

    try {
      await _dbHelper.updateItem(updatedItem);
      state = updatedItem;
    } catch (e, s) {
      logger.e("Lỗi khi cập nhật item", error: e, stackTrace: s);
    }
  }

  Future<void> deleteItem() async {
    await _dbHelper.deleteItem(state.id);
  }
}

final itemDetailProvider = StateNotifierProvider.autoDispose
    .family<ItemDetailNotifier, ClothingItem, ClothingItem>((ref, initialItem) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ItemDetailNotifier(dbHelper, initialItem);
});