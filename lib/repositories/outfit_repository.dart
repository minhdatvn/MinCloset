// lib/repositories/outfit_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:sqflite/sqflite.dart';

class OutfitRepository {
  final DatabaseHelper _dbHelper;

  OutfitRepository(this._dbHelper);

  FutureEither<List<Outfit>> getOutfits({int? limit, int? offset}) async {
    try {
      final data = await _dbHelper.getOutfits(limit: limit, offset: offset);
      final outfits = data.map((map) => Outfit.fromMap(map)).toList();
      return Right(outfits);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get outfits: $e'));
    }
  }

  FutureEither<List<Outfit>> getFixedOutfits() async {
    try {
      final maps = await _dbHelper.getFixedOutfits();
      final outfits = maps.map((map) => Outfit.fromMap(map)).toList();
      return Right(outfits);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to get fixed outfits: $e'));
    }
  }

  FutureEitherVoid insertOutfit(Outfit outfit) async {
    try {
      await _dbHelper.insertOutfit(outfit);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to insert outfit: $e'));
    }
  }

  FutureEitherVoid updateOutfit(Outfit outfit) async {
    try {
      await _dbHelper.updateOutfit(outfit);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to update outfit: $e'));
    }
  }

  FutureEitherVoid deleteOutfit(String id) async {
    try {
      // Hàm này giờ đây sẽ tự động xử lý cả việc cập nhật log
      await _dbHelper.deleteOutfit(id);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(CacheFailure('Failed to delete outfit: $e'));
    }
  }
}