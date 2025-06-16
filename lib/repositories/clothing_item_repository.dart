// lib/repositories/clothing_item_repository.dart

import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';

class ClothingItemRepository {
  final DatabaseHelper _dbHelper;

  ClothingItemRepository(this._dbHelper);

  Future<List<ClothingItem>> getAllItems() async {
    final data = await _dbHelper.getAllItems();
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<List<ClothingItem>> getItemsInCloset(String closetId) async {
    final data = await _dbHelper.getItemsInCloset(closetId);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<List<ClothingItem>> getRecentItems(int limit) async {
    final data = await _dbHelper.getRecentItems(limit);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<void> insertItem(ClothingItem item) async {
    await _dbHelper.insertItem(item.toMap());
  }

  Future<void> updateItem(ClothingItem item) async {
    await _dbHelper.updateItem(item);
  }

  Future<void> deleteItem(String id) async {
    await _dbHelper.deleteItem(id);
  }

  Future<List<ClothingItem>> searchItemsInCloset(String closetId, String query) async {
    // Nếu query rỗng, trả về tất cả item trong tủ đồ đó
    if (query.isEmpty) {
      return getItemsInCloset(closetId);
    }
    final data = await _dbHelper.searchItemsInCloset(closetId, query);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  // Thêm vào trong lớp ClothingItemRepository
  Future<List<ClothingItem>> searchAllItems(String query) async {
    final data = await _dbHelper.searchAllItems(query);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }
}