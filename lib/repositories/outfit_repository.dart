// lib/repositories/outfit_repository.dart

import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/outfit.dart';

class OutfitRepository {
  final DatabaseHelper _dbHelper;

  OutfitRepository(this._dbHelper);

  // <<< SỬA ĐỔI: Thêm limit, offset và logic chuyển đổi Map -> Model >>>
  Future<List<Outfit>> getOutfits({int? limit, int? offset}) async {
    final data = await _dbHelper.getOutfits(limit: limit, offset: offset);
    return data.map((map) => Outfit.fromMap(map)).toList();
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