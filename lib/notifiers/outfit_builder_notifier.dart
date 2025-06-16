// lib/notifiers/outfit_builder_notifier.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart'; // <<< THÊM IMPORT CHO MODEL MỚI
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/domain/providers.dart';


class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final ClothingItemRepository _clothingItemRepo;
  final SaveOutfitUseCase _saveOutfitUseCase;
  int _stickerCounter = 0;

  OutfitBuilderNotifier(this._clothingItemRepo, this._saveOutfitUseCase) : super(const OutfitBuilderState()) {
    loadAvailableItems();
  }

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

  // <<< XÓA HÀM `filterByCategory` CŨ VÀ THAY BẰNG 2 HÀM MỚI DƯỚI ĐÂY

  /// Áp dụng một bộ lọc mới cho danh sách vật phẩm.
  void applyFilters(OutfitFilter filters) {
    List<ClothingItem> newFilteredList = List.from(state.allItems);

    // Tuần tự áp dụng từng điều kiện lọc
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

  /// Xóa tất cả các bộ lọc và hiển thị lại toàn bộ vật phẩm.
  void clearFilters() {
    state = state.copyWith(
      activeFilters: const OutfitFilter(),
      filteredItems: state.allItems,
    );
  }

  // Các hàm còn lại giữ nguyên
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

  Future<void> saveOutfit(String name, Uint8List capturedImage) async {
    if (state.itemsOnCanvas.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng thêm ít nhất một món đồ để lưu!');
      return;
    }
    state = state.copyWith(isSaving: true, saveSuccess: false, errorMessage: null);
    try {
      await _saveOutfitUseCase.execute(
        name: name,
        itemsOnCanvas: state.itemsOnCanvas,
        capturedImage: capturedImage,
      );
      state = state.copyWith(isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: "Lỗi khi lưu bộ đồ: $e");
    }
  }
}

// Provider không thay đổi
final outfitBuilderProvider = StateNotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final saveOutfitUseCase = ref.watch(saveOutfitUseCaseProvider);
  return OutfitBuilderNotifier(clothingItemRepo, saveOutfitUseCase);
});