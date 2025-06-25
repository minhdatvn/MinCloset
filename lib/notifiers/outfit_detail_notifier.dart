// lib/notifiers/outfit_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/helpers/image_helper.dart';

class OutfitDetailNotifier extends StateNotifier<Outfit> {
  final OutfitRepository _outfitRepo;
  final ClothingItemRepository _clothingItemRepo;
  final ImageHelper _imageHelper;

  OutfitDetailNotifier(this._outfitRepo, this._clothingItemRepo, this._imageHelper, Outfit initialOutfit) : super(initialOutfit);

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
          final conflictingItemName = conflictingItem?.name ?? 'An item';
          
          final errorMessage = "Error: '$conflictingItemName' already belongs to another fixed outfit.";
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
      logger.e("Failed to update fixed outfit", error: e, stackTrace: s);
      return "Something went wrong."; // Trả về chuỗi lỗi chung
    }
  }

  Future<bool> deleteOutfit() async {
    // Đọc tất cả các giá trị cần thiết từ state ra biến cục bộ NGAY LẬP TỨC.
    final outfitId = state.id;
    final imagePath = state.imagePath;
    final thumbnailPath = state.thumbnailPath;

    try {
      // Từ đây trở đi, chỉ sử dụng các biến cục bộ, không truy cập 'state' nữa.
      await _imageHelper.deleteImageAndThumbnail(
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
      );
      await _outfitRepo.deleteOutfit(outfitId);
      return true; // Trả về true khi tất cả các bước thành công
    } catch (e, s) {
      logger.e("Failed to delete outfit", error: e, stackTrace: s);
      return false; // Trả về false nếu có bất kỳ lỗi nào xảy ra
    }
  }
}

final outfitDetailProvider = StateNotifierProvider.autoDispose
    .family<OutfitDetailNotifier, Outfit, Outfit>((ref, initialOutfit) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider); // <<< Lấy dependency từ provider
  return OutfitDetailNotifier(outfitRepo, clothingItemRepo, imageHelper, initialOutfit); // <<< Truyền vào constructor
});