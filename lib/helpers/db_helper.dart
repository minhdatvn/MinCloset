import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<void> _createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE clothing_items (
        id TEXT PRIMARY KEY, name TEXT, category TEXT, color TEXT, imagePath TEXT)""");
  }

  static Future<sql.Database> db() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'mincloset.db'),
        onCreate: (db, version) => _createTables(db), version: 1);
  }

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
}