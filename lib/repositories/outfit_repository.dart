// lib/repositories/outfit_repository.dart

import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/outfit.dart';

class OutfitRepository {
  final DatabaseHelper _dbHelper;

  OutfitRepository(this._dbHelper);

  Future<List<Outfit>> getOutfits() async {
    // <<< SỬA LỖI Ở ĐÂY >>>
    // Trả về trực tiếp vì _dbHelper.getOutfits() đã trả về đúng kiểu List<Outfit>
    return _dbHelper.getOutfits();
  }

  // Hàm này đã đúng vì _dbHelper.getFixedOutfits() trả về List<Map>
  Future<List<Outfit>> getFixedOutfits() async {
    final maps = await _dbHelper.getFixedOutfits();
    return maps.map((map) => Outfit.fromMap(map)).toList();
  }

  Future<void> insertOutfit(Outfit outfit) async {
    await _dbHelper.insertOutfit(outfit);
  }

  Future<void> updateOutfit(Outfit outfit) async {
    await _dbHelper.updateOutfit(outfit);
  }

  Future<void> deleteOutfit(String id) async {
    await _dbHelper.deleteOutfit(id);
  }
}