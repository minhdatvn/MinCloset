// lib/helpers/db_helper.dart
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';

class DatabaseHelper {
  // ... các hàm khác không đổi ...
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
    await db.execute("""CREATE TABLE closets (id TEXT PRIMARY KEY, name TEXT)""");
    await db.execute("""CREATE TABLE clothing_items (
        id TEXT PRIMARY KEY, name TEXT, category TEXT, color TEXT,
        imagePath TEXT, closetId TEXT, season TEXT, occasion TEXT,
        material TEXT, pattern TEXT
      )""");
    await db.execute("""CREATE TABLE outfits (
        id TEXT PRIMARY KEY,
        name TEXT,
        imagePath TEXT,
        itemIds TEXT
      )""");
  }

  // === CÁC HÀM LIÊN QUAN ĐẾN CLOSET ===
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

  // === CÁC HÀM LIÊN QUAN ĐẾN CLOTHING ITEM ===
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

  Future<List<Map<String, dynamic>>> getItemsInCloset(String closetId) async {
    final db = await instance.database;
    return db.query('clothing_items', where: 'closetId = ?', whereArgs: [closetId]);
  }
  
  Future<int> updateItem(ClothingItem item) async {
    final db = await instance.database;
    return db.update('clothing_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await instance.database;
    await db.delete('clothing_items', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await instance.database;
    return db.query('clothing_items');
  }

  Future<List<Map<String, dynamic>>> getRecentItems(int limit) async {
    final db = await instance.database;
    return db.query('clothing_items', orderBy: 'id DESC', limit: limit);
  }

  Future<List<Map<String, dynamic>>> searchItemsInCloset(String closetId, String query) async {
    final db = await instance.database;
    return db.query(
      'clothing_items',
      where: 'closetId = ? AND name LIKE ?',
      whereArgs: [closetId, '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> searchAllItems(String query) async {
    final db = await instance.database;
    if (query.isEmpty) return getAllItems();
    return db.query(
      'clothing_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  // <<< THÊM HÀM MỚI Ở ĐÂY >>>
  Future<bool> itemNameExistsInCloset(String name, String closetId, {String? currentItemId}) async {
    final db = await instance.database;
    // Chỉnh sửa câu truy vấn để loại trừ item hiện tại (khi chỉnh sửa)
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
      limit: 1, // Chỉ cần tìm 1 là đủ
    );
    return result.isNotEmpty;
  }

  // === CÁC HÀM MỚI CHO OUTFIT ===
  Future<void> insertOutfit(Outfit outfit) async {
    final db = await instance.database;
    await db.insert('outfits', outfit.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  Future<List<Outfit>> getOutfits() async {
    final db = await instance.database;
    final maps = await db.query('outfits', orderBy: 'id DESC');
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) => Outfit.fromMap(maps[i]));
  }

  Future<void> deleteOutfit(String id) async {
    final db = await instance.database;
    await db.delete('outfits', where: 'id = ?', whereArgs: [id]);
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
}