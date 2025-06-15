// lib/repositories/outfit_repository.dart

import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/outfit.dart';

class OutfitRepository {
  final DatabaseHelper _dbHelper;

  OutfitRepository(this._dbHelper);

  Future<List<Outfit>> getOutfits() async {
    // Hàm getOutfits trong db_helper đã trả về đúng kiểu List<Outfit>
    return _dbHelper.getOutfits();
  }

  Future<void> insertOutfit(Outfit outfit) async {
    await _dbHelper.insertOutfit(outfit);
  }

  Future<void> deleteOutfit(String id) async {
    await _dbHelper.deleteOutfit(id);
  }
}