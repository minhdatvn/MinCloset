// lib/helpers/db_helper.dart
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  sql.Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mincloset.db');
    return _database!;
  }

  Future<sql.Database> _initDB(String filePath) async {
    final dbPath = await sql.getDatabasesPath();
    final finalPath = path.join(dbPath, filePath);
    return await sql.openDatabase(finalPath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(sql.Database db, int version) async {
    await db.execute("""
      CREATE TABLE closets (
        id TEXT PRIMARY KEY, 
        name TEXT,
        iconName TEXT, 
        colorHex TEXT
      )
    """);
    
    // <<< THAY ĐỔI 1: Thêm cột thumbnailPath >>>
    await db.execute("""CREATE TABLE clothing_items (
        id TEXT PRIMARY KEY, name TEXT, category TEXT, color TEXT,
        imagePath TEXT,
        thumbnailPath TEXT, 
        closetId TEXT, season TEXT, occasion TEXT,
        material TEXT, pattern TEXT, isFavorite INTEGER DEFAULT 0,
        price REAL,
        notes TEXT
      )""");
    
    // <<< THAY ĐỔI 2: Thêm cột thumbnailPath >>>
    await db.execute("""CREATE TABLE outfits (
        id TEXT PRIMARY KEY,
        name TEXT,
        imagePath TEXT,
        thumbnailPath TEXT,
        itemIds TEXT,
        is_fixed INTEGER NOT NULL DEFAULT 0,
        lastWornDate TEXT
      )""");

    await db.execute("""CREATE TABLE wear_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        outfit_id TEXT,
        wear_date TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES clothing_items (id) ON DELETE CASCADE
      )""");
  }

  // === Closet Functions ===
  Future<void> insertCloset(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('closets', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getClosets() async {
    final db = await instance.database;
    return db.query('closets', orderBy: 'name ASC');
  }

  Future<int> updateCloset(Closet closet) async {
    final db = await instance.database;
    return db.update('closets', closet.toMap(), where: 'id = ?', whereArgs: [closet.id]);
  }

  Future<void> deleteCloset(String id) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('clothing_items', where: 'closetId = ?', whereArgs: [id]);
      await txn.delete('closets', where: 'id = ?', whereArgs: [id]);
    });
  }

  // === Item Functions ===
  Future<void> insertItem(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('clothing_items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }
  
  Future<void> insertBatchItems(List<Map<String, dynamic>> itemsData) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final itemMap in itemsData) {
      batch.insert('clothing_items', itemMap, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateItem(ClothingItem item) async {
    final db = await instance.database;
    return db.update('clothing_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await instance.database;
    await db.delete('clothing_items', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Map<String, dynamic>>> getAllItems({int? limit, int? offset}) async {
    final db = await instance.database;
    return db.query(
      'clothing_items',
      orderBy: 'isFavorite DESC, id DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getItemsInCloset(String closetId, {int? limit, int? offset}) async {
    final db = await instance.database;
    return db.query(
      'clothing_items',
      where: 'closetId = ?',
      whereArgs: [closetId],
      orderBy: 'isFavorite DESC, id DESC',
      limit: limit,
      offset: offset,
    );
  }
  
  Future<List<Map<String, dynamic>>> getRecentItems(int limit) async {
    final db = await instance.database;
    return db.query('clothing_items', orderBy: 'id DESC', limit: limit);
  }
  
  Future<List<Map<String, dynamic>>> searchItemsInCloset(String closetId, String query, {int? limit, int? offset}) async {
    final db = await instance.database;
    return db.query(
      'clothing_items',
      where: 'closetId = ? AND name LIKE ?',
      whereArgs: [closetId, '%$query%'],
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> searchAllItems(String query, {int? limit, int? offset}) async {
    final db = await instance.database;
    if (query.isEmpty) return getAllItems(limit: limit, offset: offset);
    return db.query(
      'clothing_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'isFavorite DESC, id DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<bool> itemNameExistsInCloset(String name, String closetId, {String? currentItemId}) async {
    final db = await instance.database;
    String whereClause = 'name = ? AND closetId = ?';
    List<dynamic> whereArgs = [name, closetId];

    if (currentItemId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(currentItemId);
    }
    
    final result = await db.query(
      'clothing_items',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getItemById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> insertWearLogs(List<Map<String, dynamic>> logs) async {
    if (logs.isEmpty) return;
    final db = await instance.database;
    final batch = db.batch();
    for (final log in logs) {
      // Dùng insert thay vì insert...replace để cho phép nhiều bản ghi giống nhau (mặc lại)
      batch.insert('wear_log', log);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteWearLogs(List<int> logIds) async {
    if (logIds.isEmpty) return;
    final db = await instance.database;
    // Xóa tất cả các bản ghi có ID nằm trong danh sách được cung cấp
    await db.delete(
      'wear_log',
      where: 'id IN (${List.filled(logIds.length, '?').join(',')})',
      whereArgs: logIds,
    );
  }

  // === Outfit Functions ===
  Future<void> insertOutfit(Outfit outfit) async {
    final db = await instance.database;
    await db.insert('outfits', outfit.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }
  
  Future<List<Map<String, dynamic>>> getOutfits({int? limit, int? offset}) async {
    final db = await instance.database;
    return db.query(
      'outfits',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<void> disassociateLogsFromOutfit(sql.DatabaseExecutor db, String outfitId) async {
    await db.update(
      'wear_log',
      {'outfit_id': null},
      where: 'outfit_id = ?',
      whereArgs: [outfitId],
    );
  }
  
  // Sửa đổi hàm deleteOutfit để sử dụng transaction
  Future<void> deleteOutfit(String id) async {
    final db = await instance.database;
    // Sử dụng transaction để đảm bảo cả hai hành động cùng thành công hoặc thất bại
    await db.transaction((txn) async {
      // 1. Cập nhật các log liên quan
      await disassociateLogsFromOutfit(txn, id);
      // 2. Xóa bộ đồ
      await txn.delete('outfits', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> updateOutfit(Outfit outfit) async {
    final db = await instance.database;
    await db.update(
      'outfits',
      outfit.toMap(),
      where: 'id = ?',
      whereArgs: [outfit.id],
    );
  }

  Future<List<Map<String, dynamic>>> getFixedOutfits() async {
    final db = await instance.database;
    return db.query('outfits', where: 'is_fixed = ?', whereArgs: [1]);
  }

  // Thêm hàm mới từ Bước 8 của Giai đoạn 1
  Future<List<Map<String, dynamic>>> getFilteredItems({
    String query = '',
    OutfitFilter? filters,
    int? limit,
    int? offset,
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (query.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      whereArgs.add('%$query%');
    }

    if (filters != null) {
      if (filters.closetId != null) {
        whereClauses.add('closetId = ?');
        whereArgs.add(filters.closetId);
      }
      if (filters.category != null) {
        whereClauses.add('category LIKE ?');
        whereArgs.add('${filters.category}%');
      }
      if (filters.colors.isNotEmpty) {
        final colorClauses = filters.colors.map((_) => 'color LIKE ?').join(' OR ');
        whereClauses.add('($colorClauses)');
        whereArgs.addAll(filters.colors.map((c) => '%$c%'));
      }
      if (filters.seasons.isNotEmpty) {
        final seasonClauses = filters.seasons.map((_) => 'season LIKE ?').join(' OR ');
        whereClauses.add('($seasonClauses)');
        whereArgs.addAll(filters.seasons.map((s) => '%$s%'));
      }
      if (filters.occasions.isNotEmpty) {
        final occasionClauses = filters.occasions.map((_) => 'occasion LIKE ?').join(' OR ');
        whereClauses.add('($occasionClauses)');
        whereArgs.addAll(filters.occasions.map((o) => '%$o%'));
      }
       if (filters.materials.isNotEmpty) {
        final materialClauses = filters.materials.map((_) => 'material LIKE ?').join(' OR ');
        whereClauses.add('($materialClauses)');
        whereArgs.addAll(filters.materials.map((m) => '%$m%'));
      }
      if (filters.patterns.isNotEmpty) {
        final patternClauses = filters.patterns.map((_) => 'pattern LIKE ?').join(' OR ');
        whereClauses.add('($patternClauses)');
        whereArgs.addAll(filters.patterns.map((p) => '%$p%'));
      }
    }
    
    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    return db.query(
      'clothing_items',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'isFavorite DESC, id DESC', 
      limit: limit,
      offset: offset,
    );
  }

  Future<void> deleteMultipleItems(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await instance.database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete('clothing_items', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> moveMultipleItems(List<String> ids, String targetClosetId) async {
    if (ids.isEmpty) return;
    final db = await instance.database;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        'clothing_items',
        {'closetId': targetClosetId},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}