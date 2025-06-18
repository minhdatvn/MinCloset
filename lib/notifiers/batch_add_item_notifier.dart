// lib/notifiers/batch_add_item_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

class BatchAddItemNotifier extends StateNotifier<BatchAddItemState> {
  final ClothingItemRepository _clothingItemRepo;

  BatchAddItemNotifier(this._clothingItemRepo, List<XFile> images)
      : super(const BatchAddItemState()) {
    // Khởi tạo trạng thái ban đầu từ danh sách ảnh
    final initialItemStates = images.map((imageFile) {
      return AddItemState(image: File(imageFile.path));
    }).toList();
    state = state.copyWith(images: images, itemStates: initialItemStates);
  }

  void updateItemDetails(int index, AddItemState updatedDetails) {
    if (index < 0 || index >= state.itemStates.length) return;
    
    final newStates = List<AddItemState>.from(state.itemStates);
    newStates[index] = updatedDetails;
    state = state.copyWith(itemStates: newStates);
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void nextPage() {
    if (state.currentIndex < state.itemStates.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousPage() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<void> saveAll() async {
    state = state.copyWith(isSaving: true, clearError: true);

    final List<ClothingItem> itemsToSave = [];
    for (int i = 0; i < state.itemStates.length; i++) {
      final itemState = state.itemStates[i];
      if (itemState.name.trim().isEmpty || itemState.selectedCategoryValue.isEmpty || itemState.selectedClosetId == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Vui lòng điền đủ thông tin bắt buộc cho món đồ ${i + 1}.',
          currentIndex: i,
        );
        return;
      }
      itemsToSave.add(ClothingItem(
        id: const Uuid().v4(),
        name: itemState.name,
        category: itemState.selectedCategoryValue,
        closetId: itemState.selectedClosetId!,
        imagePath: itemState.image!.path,
        color: itemState.selectedColors.join(', '),
        season: itemState.selectedSeasons.join(', '),
        occasion: itemState.selectedOccasions.join(', '),
        material: itemState.selectedMaterials.join(', '),
        pattern: itemState.selectedPatterns.join(', '),
      ));
    }

    try {
      await _clothingItemRepo.insertBatchItems(itemsToSave);
      state = state.copyWith(isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: "Lỗi khi lưu: $e");
    }
  }
}

final batchAddItemProvider = StateNotifierProvider.autoDispose
    .family<BatchAddItemNotifier, BatchAddItemState, List<XFile>>((ref, images) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return BatchAddItemNotifier(repo, images);
});