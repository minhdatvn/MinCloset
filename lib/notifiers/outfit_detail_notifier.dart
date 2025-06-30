// lib/notifiers/outfit_detail_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/wear_log_repository.dart'; 
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/helpers/image_helper.dart';

class OutfitDetailNotifier extends StateNotifier<Outfit> {
  final OutfitRepository _outfitRepo;
  final ClothingItemRepository _clothingItemRepo;
  final ImageHelper _imageHelper;
  final WearLogRepository _wearLogRepo; 

  OutfitDetailNotifier(this._outfitRepo, this._clothingItemRepo, this._imageHelper, this._wearLogRepo, Outfit initialOutfit) : super(initialOutfit);

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty || newName.trim() == state.name) {
      return;
    }
    final updatedOutfit = state.copyWith(name: newName.trim());
    final result = await _outfitRepo.updateOutfit(updatedOutfit);
    
    result.fold(
      (failure) => logger.e("Lỗi khi cập nhật tên bộ đồ: ${failure.message}"),
      (_) => state = updatedOutfit,
    );
  }

  // <<< VIẾT LẠI HOÀN TOÀN HÀM NÀY ĐỂ SỬA LỖI >>>
  Future<String?> toggleIsFixed(bool isFixed) async {
    if (state.isFixed == isFixed) return null;

    if (isFixed == true) {
      final currentItemIds = state.itemIds.split(',').toSet();
      final existingFixedOutfitsEither = await _outfitRepo.getFixedOutfits();

      // Sử dụng fold để xử lý kết quả
      return await existingFixedOutfitsEither.fold(
        (failure) => failure.message, // Lỗi hệ thống khi lấy fixed outfits
        (existingFixedOutfits) async {
          final outfitsToCheck = existingFixedOutfits.where((outfit) => outfit.id != state.id).toList();

          for (final fixedOutfit in outfitsToCheck) {
            final existingItemIds = fixedOutfit.itemIds.split(',').toSet();
            final intersection = currentItemIds.intersection(existingItemIds);

            if (intersection.isNotEmpty) {
              final conflictingItemId = intersection.first;
              final conflictingItemEither = await _clothingItemRepo.getItemById(conflictingItemId);
              
              return conflictingItemEither.fold(
                (failure) => failure.message, // Lỗi hệ thống khi lấy item
                (conflictingItem) => "Error: '${conflictingItem?.name ?? 'An item'}' already belongs to another fixed outfit." // Lỗi validation
              );
            }
          }
          // Nếu không có xung đột, thực hiện cập nhật
          return _updateFixedStatus(isFixed);
        },
      );
    } else {
      // Nếu chỉ là tắt isFixed, không cần kiểm tra, cứ cập nhật
      return _updateFixedStatus(isFixed);
    }
  }
  
  // Hàm helper để cập nhật trạng thái isFixed
  Future<String?> _updateFixedStatus(bool isFixed) async {
    final updatedOutfit = state.copyWith(isFixed: isFixed);
    final result = await _outfitRepo.updateOutfit(updatedOutfit);
    
    return result.fold(
      (failure) {
        logger.e("Failed to update fixed outfit", error: failure.message);
        return "Something went wrong.";
      },
      (_) {
        state = updatedOutfit;
        return null; // Thành công
      },
    );
  }

  Future<bool> deleteOutfit() async {
    final outfitId = state.id;
    final imagePath = state.imagePath;
    final thumbnailPath = state.thumbnailPath;

    await _imageHelper.deleteImageAndThumbnail(
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
    );
    
    final result = await _outfitRepo.deleteOutfit(outfitId);
    
    return result.fold(
      (failure) {
        logger.e("Failed to delete outfit", error: failure.message);
        return false;
      },
      (_) => true,
    );
  }
  Future<bool> markAsWornToday() async {
    final result = await _wearLogRepo.addWearLogForOutfit(state, DateTime.now());
    return result.isRight(); // Trả về true nếu thành công
  }
}

final outfitDetailProvider = StateNotifierProvider.autoDispose
    .family<OutfitDetailNotifier, Outfit, Outfit>((ref, initialOutfit) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  final wearLogRepo = ref.watch(wearLogRepositoryProvider);
  return OutfitDetailNotifier(outfitRepo, clothingItemRepo, imageHelper, wearLogRepo, initialOutfit);
});