// lib/notifiers/item_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/utils/logger.dart'; // <<< THÊM IMPORT NÀY

// Notifier này quản lý trạng thái là một đối tượng ClothingItem
class ItemDetailNotifier extends StateNotifier<ClothingItem> {
  final DatabaseHelper _dbHelper;

  // Khởi tạo state với món đồ ban đầu được truyền vào
  ItemDetailNotifier(this._dbHelper, ClothingItem initialItem) : super(initialItem);

  // Hàm chung để cập nhật một thuộc tính của món đồ
  Future<void> updateField({
    Set<String>? season,
    Set<String>? occasion,
    Set<String>? material,
    Set<String>? pattern,
  }) async {
    // Tạo một đối tượng item mới với giá trị được cập nhật
    final updatedItem = state.copyWith(
      season: season?.join(', '),
      occasion: occasion?.join(', '),
      material: material?.join(', '),
      pattern: pattern?.join(', '),
    );

    // <<< SỬA LỖI TẠI ĐÂY
    try {
      // Cập nhật vào CSDL
      await _dbHelper.updateItem(updatedItem);
      // Nếu thành công, cập nhật state của notifier
      // UI sẽ tự động build lại với dữ liệu mới
      state = updatedItem;
    } catch (e, s) { // Thêm `s` để lấy StackTrace
      // Thay thế print() bằng logger.e()
      logger.e(
        "Lỗi khi cập nhật item", // Tin nhắn chính
        error: e,     // Đối tượng lỗi
        stackTrace: s // Stack trace để biết lỗi xảy ra ở đâu
      );
    }
  }

  Future<void> deleteItem() async {
    await _dbHelper.deleteItem(state.id);
  }
}

// Provider cho ItemDetailNotifier
final itemDetailProvider = StateNotifierProvider.autoDispose
    .family<ItemDetailNotifier, ClothingItem, ClothingItem>((ref, initialItem) {
  final dbHelper = ref.watch(dbHelperProvider);
  return ItemDetailNotifier(dbHelper, initialItem);
});