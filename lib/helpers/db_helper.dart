// file: lib/helpers/db_helper.dart

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';

class DBHelper {
  // Hàm tạo cả 2 bảng trong CSDL
  static Future<void> _createTables(sql.Database database) async {
    // 1. Tạo bảng cho các tủ đồ
    await database.execute("""CREATE TABLE closets (
        id TEXT PRIMARY KEY,
        name TEXT
      )""");
    
    // 2. Cập nhật bảng clothing_items để thêm cột closetId
    await database.execute("""CREATE TABLE clothing_items (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        color TEXT,
        imagePath TEXT,
        closetId TEXT,
        season TEXT,
        occasion TEXT,
        material TEXT,
        pattern TEXT
      )""");
  }

  // Hàm để mở hoặc tạo CSDL
  static Future<sql.Database> db() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'mincloset.db'),
      onCreate: (db, version) {
        return _createTables(db);
      },
      version: 1,
    );
  }

  // === CÁC HÀM CHO CLOSET ===
  static Future<void> insertCloset(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    await db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }
  
  static Future<List<Map<String, dynamic>>> getClosets(String table) async {
    final db = await DBHelper.db();
    return db.query(table, orderBy: 'name ASC');
  }

  static Future<int> updateCloset(Closet closet) async {
    final db = await DBHelper.db();
    return db.update(
      'closets',
      closet.toMap(),
      where: 'id = ?',
      whereArgs: [closet.id],
    );
  }

  static Future<void> deleteCloset(String id) async {
    final db = await DBHelper.db();
    // Dùng transaction để đảm bảo cả 2 hành động xóa cùng lúc
    await db.transaction((txn) async {
      // 1. Xóa tất cả các món đồ thuộc về tủ đồ này
      await txn.delete(
        'clothing_items',
        where: 'closetId = ?',
        whereArgs: [id],
      );
      // 2. Xóa chính tủ đồ đó
      await txn.delete(
        'closets',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // === CÁC HÀM CHO CLOTHING ITEM ===
  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    await db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.db();
    return db.query(table);
  }

  static Future<List<Map<String, dynamic>>> getRecentItems(int limit) async {
    final db = await DBHelper.db();
    return db.query('clothing_items', orderBy: 'id DESC', limit: limit);
  }

  static Future<void> deleteItem(String id) async {
    final db = await DBHelper.db();
    await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateItem(ClothingItem item) async {
    final db = await DBHelper.db();
    return db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Hàm quan trọng để lấy tất cả các món đồ thuộc về một tủ đồ cụ thể
  static Future<List<Map<String, dynamic>>> getItemsInCloset(String closetId) async {
    final db = await DBHelper.db();
    return db.query(
      'clothing_items',
      where: 'closetId = ?', // Tìm các dòng có closetId khớp
      whereArgs: [closetId], // Giá trị để so sánh
    );
  }
}