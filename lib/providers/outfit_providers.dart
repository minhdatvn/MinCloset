// lib/providers/outfit_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'database_providers.dart'; // Dùng lại dbHelperProvider

// FutureProvider này sẽ cung cấp danh sách các bộ đồ đã lưu
final outfitsProvider = FutureProvider<List<Outfit>>((ref) async {
  final dbHelper = ref.read(dbHelperProvider);
  // getOutfits đã trả về List<Outfit> nên không cần map nữa
  return await dbHelper.getOutfits();
});