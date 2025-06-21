// lib/notifiers/outfit_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/utils/logger.dart';

class OutfitDetailNotifier extends StateNotifier<Outfit> {
  final OutfitRepository _outfitRepo;
  final ClothingItemRepository _clothingItemRepo;

  OutfitDetailNotifier(this._outfitRepo, this._clothingItemRepo, Outfit initialOutfit) : super(initialOutfit);

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty || newName.trim() == state.name) {
      return;
    }
    final updatedOutfit = state.copyWith(name: newName.trim());
    try {
      await _outfitRepo.updateOutfit(updatedOutfit);
      state = updatedOutfit;
    } catch (e, s) {
      logger.e("Lỗi khi cập nhật tên bộ đồ", error: e, stackTrace: s);
    }
  }

  // <<< THAY ĐỔI LOGIC HÀM NÀY ĐỂ SỬ DỤNG _clothingItemRepo >>>
  // Hàm giờ sẽ trả về String? (null nếu thành công, chuỗi lỗi nếu thất bại)
  Future<String?> toggleIsFixed(bool isFixed) async {
    if (state.isFixed == isFixed) return null;

    if (isFixed == true) {
      final currentItemIds = state.itemIds.split(',').toSet();
      final existingFixedOutfits = (await _outfitRepo.getFixedOutfits())
          .where((outfit) => outfit.id != state.id)
          .toList();

      for (final fixedOutfit in existingFixedOutfits) {
        final existingItemIds = fixedOutfit.itemIds.split(',').toSet();
        final intersection = currentItemIds.intersection(existingItemIds);

        if (intersection.isNotEmpty) {
          // <<< SỬ DỤNG REPO ĐỂ LẤY TÊN VẬT PHẨM >>>
          final conflictingItemId = intersection.first;
          final conflictingItem = await _clothingItemRepo.getItemById(conflictingItemId);
          final conflictingItemName = conflictingItem?.name ?? 'Một vật phẩm';
          
          final errorMessage = "Lỗi: '$conflictingItemName' đã thuộc một Bộ đồ cố định khác.";
          logger.w(errorMessage);
          return errorMessage; 
        }
      }
    }

    final updatedOutfit = state.copyWith(isFixed: isFixed);
    try {
      await _outfitRepo.updateOutfit(updatedOutfit);
      state = updatedOutfit;
      return null; // Trả về null báo hiệu thành công
    } catch (e, s) {
      logger.e("Lỗi khi cập nhật trạng thái cố định", error: e, stackTrace: s);
      return "Đã có lỗi không xác định xảy ra."; // Trả về chuỗi lỗi chung
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

final outfitDetailProvider = StateNotifierProvider.autoDispose
    .family<OutfitDetailNotifier, Outfit, Outfit>((ref, initialOutfit) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  return OutfitDetailNotifier(outfitRepo, clothingItemRepo, initialOutfit);
});