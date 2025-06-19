// lib/notifiers/batch_add_item_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

class BatchAddItemNotifier extends StateNotifier<BatchAddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final Ref _ref;

  BatchAddItemNotifier(this._clothingItemRepo, this._ref)
      : super(const BatchAddItemState());

  String _normalizeCategory(String? rawCategory) {
    if (rawCategory == null || rawCategory.trim().isEmpty) {
      return 'Khác > Khác';
    }
    if (!rawCategory.contains('>') && AppOptions.categories.containsKey(rawCategory)) {
      return '$rawCategory > Khác';
    }
    final parts = rawCategory.split(' > ');
    if (!AppOptions.categories.containsKey(parts.first)) {
        return 'Khác > Khác';
    }
    return rawCategory;
  }

  /// <<< HÀM HELPER MỚI VÀ THÔNG MINH HƠN >>>
  /// Xử lý giá trị đa lựa chọn (material, pattern) từ AI
  Set<String> _normalizeMultiSelect(dynamic rawValue, List<String> validOptions) {
    final selections = <String>{};
    if (rawValue == null) {
      return selections;
    }

    final validOptionsSet = validOptions.toSet();
    bool hasUnknowns = false;

    List<String> valuesToProcess = [];
    if (rawValue is String) {
      valuesToProcess = [rawValue];
    } else if (rawValue is List) {
      valuesToProcess = rawValue.map((e) => e.toString()).toList();
    }

    for (final value in valuesToProcess) {
      if (validOptionsSet.contains(value)) {
        selections.add(value);
      } else {
        hasUnknowns = true;
      }
    }
    
    if (hasUnknowns && validOptionsSet.contains('Khác')) {
      selections.add('Khác');
    }
    
    return selections;
  }

  Future<void> analyzeAllImages(List<XFile> images) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final useCase = _ref.read(analyzeItemUseCaseProvider);
    final List<Future<Map<String, dynamic>>> analysisTasks = [];

    for (final image in images) {
      analysisTasks.add(useCase.execute(image));
    }

    try {
      final results = await Future.wait(analysisTasks);
      final List<AddItemState> analyzedItemStates = [];

      for (int i = 0; i < images.length; i++) {
        final result = results[i];
        final imageFile = images[i];
        
        final category = _normalizeCategory(result['category'] as String?);
        final colors = (result['colors'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {};
        
        // <<< ÁP DỤNG HÀM XỬ LÝ MỚI >>>
        final materials = _normalizeMultiSelect(result['material'], AppOptions.materials.map((e) => e.name).toList());
        final patterns = _normalizeMultiSelect(result['pattern'], AppOptions.patterns.map((e) => e.name).toList());

        analyzedItemStates.add(
          AddItemState(
            image: File(imageFile.path),
            selectedCategoryValue: category,
            selectedColors: colors,
            selectedMaterials: materials,
            selectedPatterns: patterns,
          ),
        );
      }
      
      state = state.copyWith(
        isLoading: false,
        itemStates: analyzedItemStates,
        analysisSuccess: true,
      );

    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Các hàm còn lại không thay đổi
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
    // Logic lưu không thay đổi
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

final batchAddItemProvider = StateNotifierProvider.autoDispose<BatchAddItemNotifier, BatchAddItemState>((ref) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return BatchAddItemNotifier(repo, ref);
});