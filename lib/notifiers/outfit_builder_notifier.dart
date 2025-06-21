// lib/notifiers/outfit_builder_notifier.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart'; // <<< THÊM IMPORT
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/domain/providers.dart';


class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final ClothingItemRepository _clothingItemRepo;
  final OutfitRepository _outfitRepo; // <<< THÊM REPO MỚI
  final SaveOutfitUseCase _saveOutfitUseCase;
  int _stickerCounter = 0;

  OutfitBuilderNotifier(this._clothingItemRepo, this._outfitRepo, this._saveOutfitUseCase) : super(const OutfitBuilderState()) {
    loadAvailableItems();
  }

  // ... các hàm loadAvailableItems, applyFilters, clearFilters, addItemToCanvas, ... giữ nguyên ...
  Future<void> loadAvailableItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _clothingItemRepo.getAllItems();
      state = state.copyWith(
        allItems: items,
        filteredItems: items,
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(errorMessage: "Không thể tải danh sách đồ", isLoading: false);
    }
  }

  void applyFilters(OutfitFilter filters) {
    List<ClothingItem> newFilteredList = List.from(state.allItems);

    if (filters.closetId != null) {
      newFilteredList.retainWhere((item) => item.closetId == filters.closetId);
    }
    if (filters.category != null) {
      newFilteredList.retainWhere((item) => item.category.startsWith(filters.category!));
    }
    if (filters.colors.isNotEmpty) {
      newFilteredList.retainWhere((item) => filters.colors.any((color) => item.color.contains(color)));
    }
    if (filters.seasons.isNotEmpty) {
      newFilteredList.retainWhere((item) => filters.seasons.any((season) => item.season?.contains(season) ?? false));
    }
    if (filters.occasions.isNotEmpty) {
      newFilteredList.retainWhere((item) => filters.occasions.any((occasion) => item.occasion?.contains(occasion) ?? false));
    }

    state = state.copyWith(
      activeFilters: filters,
      filteredItems: newFilteredList,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      activeFilters: const OutfitFilter(),
      filteredItems: state.allItems,
    );
  }

  void addItemToCanvas(ClothingItem item) {
    final newStickerId = 'sticker_${_stickerCounter++}';
    final newCanvasItems = Map<String, ClothingItem>.from(state.itemsOnCanvas);
    newCanvasItems[newStickerId] = item;
    state = state.copyWith(itemsOnCanvas: newCanvasItems, selectedStickerId: newStickerId);
  }

  void selectSticker(String stickerId) {
    final itemToBringForward = state.itemsOnCanvas[stickerId];
    if (itemToBringForward == null) return;
    final newCanvasItems = Map<String, ClothingItem>.from(state.itemsOnCanvas);
    newCanvasItems.remove(stickerId);
    newCanvasItems[stickerId] = itemToBringForward;
    state = state.copyWith(itemsOnCanvas: newCanvasItems, selectedStickerId: stickerId);
  }

  void deselectAllStickers() {
    state = state.copyWith(clearSelectedSticker: true);
  }

  void deleteSticker(String stickerId) {
    final newCanvasItems = Map<String, ClothingItem>.from(state.itemsOnCanvas);
    newCanvasItems.remove(stickerId);
    state = state.copyWith(itemsOnCanvas: newCanvasItems, clearSelectedSticker: true);
  }

  // <<< CẬP NHẬT HOÀN TOÀN HÀM saveOutfit >>>
  Future<void> saveOutfit(String name, bool isFixed, Uint8List capturedImage) async {
    if (state.itemsOnCanvas.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng thêm ít nhất một món đồ để lưu!');
      return;
    }
    state = state.copyWith(isSaving: true, saveSuccess: false, errorMessage: null);

    // --- LOGIC KIỂM TRA RÀNG BUỘC ---
    if (isFixed) {
      final currentItemIds = state.itemsOnCanvas.values.map((item) => item.id).toSet();
      final existingFixedOutfits = await _outfitRepo.getFixedOutfits();
      
      for (final fixedOutfit in existingFixedOutfits) {
        final existingItemIds = fixedOutfit.itemIds.split(',').toSet();
        final intersection = currentItemIds.intersection(existingItemIds);

        if (intersection.isNotEmpty) {
          final conflictingItemId = intersection.first;
          final conflictingItem = await _clothingItemRepo.getItemById(conflictingItemId); // Giả sử có hàm này
          final conflictingItemName = conflictingItem?.name ?? 'Một vật phẩm';
          
          state = state.copyWith(
            isSaving: false,
            errorMessage: "Lỗi: '$conflictingItemName' đã thuộc một Bộ đồ cố định khác.",
          );
          return;
        }
      }
    }
    // --- KẾT THÚC LOGIC KIỂM TRA ---

    try {
      await _saveOutfitUseCase.execute(
        name: name,
        isFixed: isFixed, // Truyền cờ isFixed
        itemsOnCanvas: state.itemsOnCanvas,
        capturedImage: capturedImage,
      );
      state = state.copyWith(isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: "Lỗi khi lưu bộ đồ: $e");
    }
  }
}

// <<< CẬP NHẬT PROVIDER ĐỂ TRUYỀN ĐỦ REPOSITORY >>>
final outfitBuilderProvider = StateNotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider); // Lấy outfit repo
  final saveOutfitUseCase = ref.watch(saveOutfitUseCaseProvider);
  return OutfitBuilderNotifier(clothingItemRepo, outfitRepo, saveOutfitUseCase);
});