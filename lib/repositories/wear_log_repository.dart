// lib/repositories/wear_log_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/wear_log.dart';
import 'package:sqflite/sqflite.dart';

class WearLogRepository {
  final DatabaseHelper _dbHelper;

  WearLogRepository(this._dbHelper);

  FutureEitherVoid addBatchWearLogs(List<Map<String, dynamic>> logsData) async {
    try {
      await _dbHelper.insertWearLogs(logsData);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to log items wear: $e'));
    }
  }

  FutureEither<List<WearLog>> getLogsForDateRange(DateTime start, DateTime end) async {
    try {
      final db = await _dbHelper.database;
      final startDateString = start.toIso8601String().split('T').first;
      final endDateString = end.toIso8601String().split('T').first;

      final maps = await db.query(
        'wear_log',
        where: 'wear_date BETWEEN ? AND ?',
        whereArgs: [startDateString, endDateString],
        orderBy: 'wear_date DESC',
      );
      
      final logs = maps.map((map) => WearLog.fromMap(map)).toList();
      return Right(logs);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get wear logs: $e'));
    }
  }
}