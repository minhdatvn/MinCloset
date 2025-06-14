// file: lib/helpers/db_helper.dart
// file: lib/helpers/db_helper.dart
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';

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
  }

  // HÀM _createDB ĐÃ ĐƯỢC XÓA KHỎI ĐÂY

  // === CÁC HÀM TƯƠNG TÁC CSDL GIỮ NGUYÊN ===
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
}