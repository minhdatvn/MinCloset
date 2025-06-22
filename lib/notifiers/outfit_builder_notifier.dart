// lib/notifiers/outfit_builder_notifier.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';

class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final ClothingItemRepository _clothingItemRepo;
  final SaveOutfitUseCase _saveOutfitUseCase;
  final OutfitRepository _outfitRepo;
  // <<< XÓA BỎ: không cần dùng đến _ref >>>

  OutfitBuilderNotifier(
    this._clothingItemRepo,
    this._saveOutfitUseCase,
    this._outfitRepo,
    // <<< XÓA BỎ: tham số _ref >>>
  ) : super(const OutfitBuilderState()) {
    loadAvailableItems();
  }

  Future<void> loadAvailableItems() async {
    state = state.copyWith(isLoading: true, saveSuccess: false, errorMessage: null);
    try {
      final items = await _clothingItemRepo.getAllItems();
      state = state.copyWith(
        allItems: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Could not load items for sticker drawer.",
        isLoading: false,
      );
    }
  }

  Future<void> saveOutfit({
    required String name,
    required bool isFixed,
    required Map<String, ClothingItem> itemsOnCanvas,
    required Uint8List capturedImage,
  }) async {
    state = state.copyWith(isSaving: true, saveSuccess: false, errorMessage: null);

    if (itemsOnCanvas.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng thêm ít nhất một vật phẩm để lưu bộ đồ!', isSaving: false);
      return;
    }

    if (isFixed) {
      final newItemIds = itemsOnCanvas.values.map((item) => item.id).toSet();
      final existingFixedOutfits = await _outfitRepo.getFixedOutfits();

      for (final fixedOutfit in existingFixedOutfits) {
        final existingItemIds = fixedOutfit.itemIds.split(',').toSet();
        final intersection = newItemIds.intersection(existingItemIds);

        if (intersection.isNotEmpty) {
          final conflictingItemId = intersection.first;
          final conflictingItem = await _clothingItemRepo.getItemById(conflictingItemId);
          final errorMessage = "Lỗi: '${conflictingItem?.name ?? 'Một vật phẩm'}' đã thuộc một Bộ đồ cố định khác.";
          state = state.copyWith(errorMessage: errorMessage, isSaving: false);
          return;
        }
      }
    }

    try {
      await _saveOutfitUseCase.execute(
        name: name,
        isFixed: isFixed,
        itemsOnCanvas: itemsOnCanvas,
        capturedImage: capturedImage,
      );
      state = state.copyWith(saveSuccess: true, isSaving: false);
    } catch (e) {
      state = state.copyWith(errorMessage: "Lỗi khi lưu bộ đồ: $e", isSaving: false);
    }
  }
}

final outfitBuilderProvider =
    StateNotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final saveOutfitUseCase = ref.watch(saveOutfitUseCaseProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return OutfitBuilderNotifier(clothingItemRepo, saveOutfitUseCase, outfitRepo); // <<< XÓA BỎ: đối số ref >>>
});