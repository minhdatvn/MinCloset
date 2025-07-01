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
    final result = await _outfitRepo.updateOutfit(updatedOutfit);
    
    result.fold(
      (failure) => logger.e("Lỗi khi cập nhật tên bộ đồ: ${failure.message}"),
      (_) => state = updatedOutfit,
    );
  }

  Future<String?> toggleIsFixed(bool isFixed) async {
    if (state.isFixed == isFixed) return null;

    if (isFixed == true) {
      final currentItemIds = state.itemIds.split(',').toSet();
      final existingFixedOutfitsEither = await _outfitRepo.getFixedOutfits();

      return await existingFixedOutfitsEither.fold(
        (failure) => failure.message,
        (existingFixedOutfits) async {
          final outfitsToCheck = existingFixedOutfits.where((outfit) => outfit.id != state.id).toList();

          for (final fixedOutfit in outfitsToCheck) {
            final existingItemIds = fixedOutfit.itemIds.split(',').toSet();
            final intersection = currentItemIds.intersection(existingItemIds);

            if (intersection.isNotEmpty) {
              final conflictingItemId = intersection.first;
              final conflictingItemEither = await _clothingItemRepo.getItemById(conflictingItemId);
              
              return conflictingItemEither.fold(
                (failure) => failure.message,
                (conflictingItem) => "Error: '${conflictingItem?.name ?? 'An item'}' already belongs to another fixed outfit."
              );
            }
          }
          return _updateFixedStatus(isFixed);
        },
      );
    } else {
      return _updateFixedStatus(isFixed);
    }
  }
  
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
}

final outfitDetailProvider = StateNotifierProvider.autoDispose
    .family<OutfitDetailNotifier, Outfit, Outfit>((ref, initialOutfit) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  return OutfitDetailNotifier(outfitRepo, clothingItemRepo, imageHelper, initialOutfit);
});