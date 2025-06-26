// lib/repositories/clothing_item_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:sqflite/sqflite.dart';

class ClothingItemRepository {
  final DatabaseHelper _dbHelper;

  ClothingItemRepository(this._dbHelper);

  FutureEither<List<ClothingItem>> getAllItems({int? limit, int? offset}) async {
    try {
      final data = await _dbHelper.getAllItems(limit: limit, offset: offset);
      final items = data.map((map) => ClothingItem.fromMap(map)).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get items: $e'));
    }
  }
  
  FutureEither<ClothingItem?> getItemById(String id) async {
    try {
      final map = await _dbHelper.getItemById(id);
      if (map != null) {
        return Right(ClothingItem.fromMap(map));
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get item by ID: $e'));
    }
  }

  FutureEither<List<ClothingItem>> getItemsInCloset(String closetId, {int? limit, int? offset}) async {
     try {
      final data = await _dbHelper.getItemsInCloset(closetId, limit: limit, offset: offset);
      final items = data.map((map) => ClothingItem.fromMap(map)).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get items in closet: $e'));
    }
  }

  FutureEither<List<ClothingItem>> getRecentItems(int limit) async {
    try {
      final data = await _dbHelper.getRecentItems(limit);
      final items = data.map((map) => ClothingItem.fromMap(map)).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get recent items: $e'));
    }
  }

  FutureEitherVoid insertItem(ClothingItem item) async {
    try {
      await _dbHelper.insertItem(item.toMap());
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to insert item: $e'));
    }
  }

  FutureEitherVoid insertBatchItems(List<ClothingItem> items) async {
    try {
      final itemsData = items.map((item) => item.toMap()).toList();
      await _dbHelper.insertBatchItems(itemsData);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to insert batch items: $e'));
    }
  }

  FutureEitherVoid updateItem(ClothingItem item) async {
    try {
      await _dbHelper.updateItem(item);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to update item: $e'));
    }
  }

  FutureEitherVoid deleteItem(String id) async {
    try {
      await _dbHelper.deleteItem(id);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to delete item: $e'));
    }
  }

  FutureEither<List<ClothingItem>> searchItemsInCloset(String closetId, String query, {int? limit, int? offset}) async {
    try {
      if (query.isEmpty) {
        return getItemsInCloset(closetId, limit: limit, offset: offset);
      }
      final data = await _dbHelper.searchItemsInCloset(closetId, query, limit: limit, offset: offset);
      final items = data.map((map) => ClothingItem.fromMap(map)).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to search items in closet: $e'));
    }
  }

  FutureEither<List<ClothingItem>> searchAllItems(String query, {int? limit, int? offset}) async {
    try {
      final data = await _dbHelper.searchAllItems(query, limit: limit, offset: offset);
      final items = data.map((map) => ClothingItem.fromMap(map)).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to search all items: $e'));
    }
  }

  FutureEither<bool> itemNameExists(String name, String closetId, {String? currentItemId}) async {
    try {
      final result = await _dbHelper.itemNameExistsInCloset(name, closetId, currentItemId: currentItemId);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to check if item name exists: $e'));
    }
  }

  FutureEither<List<ClothingItem>> getFilteredItems({
    String query = '',
    OutfitFilter? filters,
    int? limit,
    int? offset,
  }) async {
    try {
      final data = await _dbHelper.getFilteredItems(
        query: query,
        filters: filters,
        limit: limit,
        offset: offset,
      );
      final items = data.map((map) => ClothingItem.fromMap(map)).toList();
      return Right(items);
    } on DatabaseException catch(e) {
      return Left(CacheFailure('Failed to get filtered items: $e'));
    }
  }

  FutureEitherVoid deleteMultipleItems(Set<String> ids) async {
    try {
      await _dbHelper.deleteMultipleItems(ids.toList());
      return const Right(unit);
    } on DatabaseException catch(e) {
      return Left(CacheFailure('Failed to delete multiple items: $e'));
    }
  }

  FutureEitherVoid moveMultipleItems(Set<String> ids, String targetClosetId) async {
    try {
      await _dbHelper.moveMultipleItems(ids.toList(), targetClosetId);
      return const Right(unit);
    } on DatabaseException catch(e) {
      return Left(CacheFailure('Failed to move multiple items: $e'));
    }
  }
}