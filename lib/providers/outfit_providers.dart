// lib/providers/outfit_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart'; // <<< THAY ĐỔI IMPORT

// FutureProvider này sẽ cung cấp danh sách các bộ đồ đã lưu
final outfitsProvider = FutureProvider<List<Outfit>>((ref) {
  // <<< THAY ĐỔI Ở ĐÂY
  final outfitRepository = ref.watch(outfitRepositoryProvider);
  return outfitRepository.getOutfits();
});