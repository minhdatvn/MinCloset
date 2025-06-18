// lib/notifiers/batch_add_item_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/providers.dart'; // <<< THÊM
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

class BatchAddItemNotifier extends StateNotifier<BatchAddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final Ref _ref; // <<< THÊM REF

  // <<< CẬP NHẬT HÀM KHỞI TẠO
  BatchAddItemNotifier(this._clothingItemRepo, this._ref, List<XFile> images)
      : super(const BatchAddItemState()) {
    final initialItemStates = images.map((imageFile) {
      return AddItemState(image: File(imageFile.path));
    }).toList();
    state = state.copyWith(images: images, itemStates: initialItemStates);
    
    // Tự động phân tích ảnh đầu tiên khi màn hình được mở
    if (images.isNotEmpty) {
      analyzeItemAtIndex(0);
    }
  }

  void updateItemDetails(int index, AddItemState updatedDetails) {
    if (index < 0 || index >= state.itemStates.length) return;
    
    final newStates = List<AddItemState>.from(state.itemStates);
    newStates[index] = updatedDetails;
    state = state.copyWith(itemStates: newStates);
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
    // Khi người dùng lướt đến trang mới, kiểm tra và phân tích nếu cần
    analyzeItemAtIndex(index);
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

  // <<< HÀM MỚI ĐỂ PHÂN TÍCH ẢNH TẠI MỘT VỊ TRÍ CỤ THỂ
  Future<void> analyzeItemAtIndex(int index) async {
    if (index < 0 || index >= state.itemStates.length) return;

    final itemToAnalyze = state.itemStates[index];
    // Chỉ phân tích nếu nó chưa từng được phân tích (dựa vào danh mục) và không đang trong quá trình phân tích
    if (itemToAnalyze.selectedCategoryValue.isNotEmpty || itemToAnalyze.isAnalyzing) {
      return;
    }

    // Đánh dấu là đang phân tích cho item này
    updateItemDetails(index, itemToAnalyze.copyWith(isAnalyzing: true));

    final imageFile = state.images[index];
    final useCase = _ref.read(analyzeItemUseCaseProvider);
    final result = await useCase.execute(imageFile);

    if (result.isNotEmpty && mounted) {
      final category = result['category'] as String?;
      final colors = (result['colors'] as List<dynamic>?)?.map((e) => e.toString()).toSet();
      final material = (result['material'] as String?) != null ? {result['material'] as String} : null;
      final pattern = (result['pattern'] as String?) != null ? {result['pattern'] as String} : null;
      
      final analyzedState = itemToAnalyze.copyWith(
        isAnalyzing: false, // Phân tích xong
        selectedCategoryValue: category,
        selectedColors: colors,
        selectedMaterials: material,
        selectedPatterns: pattern,
      );
      updateItemDetails(index, analyzedState);
    } else if (mounted) {
      // Nếu có lỗi hoặc không có kết quả, vẫn tắt trạng thái analyzing
      updateItemDetails(index, itemToAnalyze.copyWith(isAnalyzing: false));
    }
  }

  Future<void> saveAll() async {
    state = state.copyWith(isSaving: true, clearError: true);

    final List<ClothingItem> itemsToSave = [];
    for (int i = 0; i < state.itemStates.length; i++) {
      final itemState = state.itemStates[i];
      if (itemState.name.trim().isEmpty) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Vui lòng nhập tên cho món đồ ${i + 1}.',
          currentIndex: i,
        );
        return;
      }
       if (itemState.selectedClosetId == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Vui lòng chọn tủ đồ cho món đồ ${i + 1}.',
          currentIndex: i,
        );
        return;
      }
      if (itemState.selectedCategoryValue.isEmpty) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Vui lòng chọn danh mục cho món đồ ${i + 1}.',
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

// <<< CẬP NHẬT PROVIDER ĐỂ TRUYỀN REF VÀO NOTIFIER
final batchAddItemProvider = StateNotifierProvider.autoDispose
    .family<BatchAddItemNotifier, BatchAddItemState, List<XFile>>((ref, images) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return BatchAddItemNotifier(repo, ref, images);
});