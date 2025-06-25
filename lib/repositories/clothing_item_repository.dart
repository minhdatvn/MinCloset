// lib/repositories/clothing_item_repository.dart

import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';

class ClothingItemRepository {
  final DatabaseHelper _dbHelper;

  ClothingItemRepository(this._dbHelper);

  // <<< SỬA ĐỔI: Thêm limit và offset >>>
  Future<List<ClothingItem>> getAllItems({int? limit, int? offset}) async {
    final data = await _dbHelper.getAllItems(limit: limit, offset: offset);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }
  
  Future<ClothingItem?> getItemById(String id) async {
    final map = await _dbHelper.getItemById(id);
    if (map != null) {
      return ClothingItem.fromMap(map);
    }
    return null;
  }

  // <<< SỬA ĐỔI: Thêm limit và offset >>>
  Future<List<ClothingItem>> getItemsInCloset(String closetId, {int? limit, int? offset}) async {
    final data = await _dbHelper.getItemsInCloset(closetId, limit: limit, offset: offset);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<List<ClothingItem>> getRecentItems(int limit) async {
    final data = await _dbHelper.getRecentItems(limit);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<void> insertItem(ClothingItem item) async {
    await _dbHelper.insertItem(item.toMap());
  }

  Future<void> insertBatchItems(List<ClothingItem> items) async {
    final itemsData = items.map((item) => item.toMap()).toList();
    await _dbHelper.insertBatchItems(itemsData);
  }

  Future<void> updateItem(ClothingItem item) async {
    await _dbHelper.updateItem(item);
  }

  Future<void> deleteItem(String id) async {
    await _dbHelper.deleteItem(id);
  }

  // <<< SỬA ĐỔI: Thêm limit và offset >>>
  Future<List<ClothingItem>> searchItemsInCloset(String closetId, String query, {int? limit, int? offset}) async {
    if (query.isEmpty) {
      return getItemsInCloset(closetId, limit: limit, offset: offset);
    }
    final data = await _dbHelper.searchItemsInCloset(closetId, query, limit: limit, offset: offset);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  // <<< SỬA ĐỔI: Thêm limit và offset >>>
  Future<List<ClothingItem>> searchAllItems(String query, {int? limit, int? offset}) async {
    final data = await _dbHelper.searchAllItems(query, limit: limit, offset: offset);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<bool> itemNameExists(String name, String closetId, {String? currentItemId}) {
    return _dbHelper.itemNameExistsInCloset(name, closetId, currentItemId: currentItemId);
  }

  Future<List<ClothingItem>> getFilteredItems({
    String query = '',
    OutfitFilter? filters,
    int? limit,
    int? offset,
  }) async {
    final data = await _dbHelper.getFilteredItems(
      query: query,
      filters: filters,
      limit: limit,
      offset: offset,
    );
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<void> deleteMultipleItems(Set<String> ids) async {
    await _dbHelper.deleteMultipleItems(ids.toList());
  }

  Future<void> moveMultipleItems(Set<String> ids, String targetClosetId) async {
    await _dbHelper.moveMultipleItems(ids.toList(), targetClosetId);
  }
}