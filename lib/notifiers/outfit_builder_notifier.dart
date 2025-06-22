// lib/notifiers/outfit_builder_notifier.dart

import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/outfit_builder_state.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';

class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final ClothingItemRepository _clothingItemRepo;
  final SaveOutfitUseCase _saveOutfitUseCase;

  OutfitBuilderNotifier(this._clothingItemRepo, this._saveOutfitUseCase)
      : super(const OutfitBuilderState()) {
    // Tự động tải danh sách vật phẩm ngay khi notifier được tạo
    loadAvailableItems();
  }

  /// Tải tất cả vật phẩm từ CSDL để chuẩn bị cho ngăn sticker.
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

  /// Lưu bộ đồ. Hàm này sẽ được gọi từ giao diện editor mới.
  /// [itemsOnCanvas]: Ta cần một cách để theo dõi các item đã được dùng.
  /// Logic này sẽ được hoàn thiện ở bước xây dựng UI.
  Future<void> saveOutfit({
    required String name,
    required bool isFixed,
    required Map<String, ClothingItem> itemsOnCanvas,
    required Uint8List capturedImage,
  }) async {
    if (itemsOnCanvas.isEmpty) {
      state = state.copyWith(errorMessage: 'Please add at least one item to save the outfit!');
      return;
    }
    // Logic kiểm tra xung đột cho bộ đồ cố định có thể được thêm vào đây sau.
    // Hiện tại, chúng ta sẽ gọi trực tiếp UseCase để lưu.

    try {
      await _saveOutfitUseCase.execute(
        name: name,
        isFixed: isFixed,
        itemsOnCanvas: itemsOnCanvas,
        capturedImage: capturedImage,
      );
      state = state.copyWith(saveSuccess: true);
    } catch (e) {
      state = state.copyWith(errorMessage: "Error saving outfit: $e");
    }
  }
}

// Provider không thay đổi nhiều, chỉ cần đảm bảo truyền đúng các dependency
final outfitBuilderProvider =
    StateNotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final saveOutfitUseCase = ref.watch(saveOutfitUseCaseProvider);
  return OutfitBuilderNotifier(clothingItemRepo, saveOutfitUseCase);
});