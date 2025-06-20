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

  Future<List<ClothingItem>> searchItemsInCloset(String closetId, String query) async {
    if (query.isEmpty) {
      return getItemsInCloset(closetId);
    }
    final data = await _dbHelper.searchItemsInCloset(closetId, query);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<List<ClothingItem>> searchAllItems(String query) async {
    final data = await _dbHelper.searchAllItems(query);
    return data.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<bool> itemNameExists(String name, String closetId, {String? currentItemId}) {
    return _dbHelper.itemNameExistsInCloset(name, closetId, currentItemId: currentItemId);
  }
}