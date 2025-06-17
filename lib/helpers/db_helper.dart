// file: lib/helpers/db_helper.dart
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';

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
    await db.execute("""CREATE TABLE closets (id TEXT PRIMARY KEY, name TEXT)""");
    await db.execute("""CREATE TABLE clothing_items (
        id TEXT PRIMARY KEY, name TEXT, category TEXT, color TEXT,
        imagePath TEXT, closetId TEXT, season TEXT, occasion TEXT,
        material TEXT, pattern TEXT
      )""");
    // Thêm bảng outfits mới
    await db.execute("""CREATE TABLE outfits (
        id TEXT PRIMARY KEY,
        name TEXT,
        imagePath TEXT,
        itemIds TEXT
      )""");
  }

  // === CÁC HÀM CŨ GIỮ NGUYÊN (insertCloset, getClosets, ...) ===
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

  Future<void> insertItem(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert('clothing_items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
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

  // === CÁC HÀM MỚI CHO OUTFIT ===

  /// Thêm một bộ đồ mới vào CSDL
  Future<void> insertOutfit(Outfit outfit) async {
    final db = await instance.database;
    await db.insert('outfits', outfit.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  /// Lấy tất cả các bộ đồ từ CSDL
  Future<List<Outfit>> getOutfits() async {
    final db = await instance.database;
    final maps = await db.query('outfits', orderBy: 'id DESC');
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) => Outfit.fromMap(maps[i]));
  }

  /// Xóa một bộ đồ khỏi CSDL bằng ID
  Future<void> deleteOutfit(String id) async {
    final db = await instance.database;
    await db.delete('outfits', where: 'id = ?', whereArgs: [id]);
  }

  ///Tìm trong tủ đồ
  Future<List<Map<String, dynamic>>> searchItemsInCloset(String closetId, String query) async {
    final db = await instance.database;
    // Dùng LIKE với ký tự '%' để tìm kiếm các tên chứa chuỗi query
    return db.query(
      'clothing_items',
      where: 'closetId = ? AND name LIKE ?',
      whereArgs: [closetId, '%$query%'],
    );
  }

  ///Tìm tất cả
  Future<List<Map<String, dynamic>>> searchAllItems(String query) async {
    final db = await instance.database;
    if (query.isEmpty) return getAllItems();
    return db.query(
      'clothing_items',
      where: 'name LIKE ?', // Bỏ điều kiện `closetId`
      whereArgs: ['%$query%'],
    );
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