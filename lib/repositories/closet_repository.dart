// lib/repositories/closet_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:sqflite/sqflite.dart';

// Lớp này là lớp trung gian, chịu trách nhiệm về dữ liệu Closet.
class ClosetRepository {
  // Nó phụ thuộc vào DatabaseHelper, nhưng chỉ là chi tiết triển khai bên trong.
  final DatabaseHelper _dbHelper;

  // Constructor yêu cầu một DatabaseHelper (dependency injection).
  ClosetRepository(this._dbHelper);

  // Phương thức này lấy danh sách tủ đồ.
  FutureEither<List<Closet>> getClosets() async {
    try {
      final data = await _dbHelper.getClosets();
      final closets = data.map((map) => Closet.fromMap(map)).toList();
      return Right(closets);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to load closets from database: $e'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  // Tương tự cho các phương thức khác.
  FutureEitherVoid insertCloset(Closet closet) async {
    try {
      await _dbHelper.insertCloset(closet.toMap());
      return const Right(unit); // 'unit' đại diện cho kết quả thành công không có giá trị (void)
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to save closet: $e'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  FutureEitherVoid updateCloset(Closet closet) async {
    try {
      await _dbHelper.updateCloset(closet);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to update closet: $e'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  FutureEitherVoid deleteCloset(String id) async {
    try {
      await _dbHelper.deleteCloset(id);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to delete closet: $e'));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}