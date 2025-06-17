// lib/notifiers/outfit_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/utils/logger.dart';

class OutfitDetailNotifier extends StateNotifier<Outfit> {
  final OutfitRepository _outfitRepo;

  OutfitDetailNotifier(this._outfitRepo, Outfit initialOutfit) : super(initialOutfit);

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty || newName.trim() == state.name) {
      return;
    }

    final updatedOutfit = state.copyWith(name: newName.trim());

    try {
      await _outfitRepo.updateOutfit(updatedOutfit);
      // Nếu thành công, cập nhật state của notifier
      state = updatedOutfit;
    } catch (e, s) {
      logger.e("Lỗi khi cập nhật tên bộ đồ", error: e, stackTrace: s);
    }
  }

  Future<void> deleteOutfit() async {
    try {
      await _outfitRepo.deleteOutfit(state.id);
    } catch (e, s) {
      logger.e("Lỗi khi xóa bộ đồ", error: e, stackTrace: s);
    }
  }
}

// Provider.family để có thể truyền vào bộ đồ ban đầu
final outfitDetailProvider = StateNotifierProvider.autoDispose
    .family<OutfitDetailNotifier, Outfit, Outfit>((ref, initialOutfit) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return OutfitDetailNotifier(outfitRepo, initialOutfit);
});