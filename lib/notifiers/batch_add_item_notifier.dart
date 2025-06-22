// lib/notifiers/batch_add_item_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:uuid/uuid.dart';

class BatchAddItemNotifier extends StateNotifier<BatchAddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final Ref _ref;

  BatchAddItemNotifier(this._clothingItemRepo, this._ref)
      : super(const BatchAddItemState());

  // <<< THÊM HÀM MỚI Ở ĐÂY >>>
  Set<String> _normalizeColors(List<dynamic>? rawColors) {
    if (rawColors == null) return {};
    final validColorNames = AppOptions.colors.keys.toSet();
    final selections = <String>{};
    for (final color in rawColors) {
      if (validColorNames.contains(color.toString())) {
        selections.add(color.toString());
      }
    }
    return selections;
  }

  String _normalizeCategory(String? rawCategory) {
    if (rawCategory == null || rawCategory.trim().isEmpty) { return 'Khác > Khác'; }
    if (!rawCategory.contains('>') && AppOptions.categories.containsKey(rawCategory)) { return '$rawCategory > Khác'; }
    final parts = rawCategory.split(' > ');
    if (!AppOptions.categories.containsKey(parts.first)) { return 'Khác > Khác'; }
    return rawCategory;
  }
  Set<String> _normalizeMultiSelect(dynamic rawValue, List<String> validOptions) {
    final selections = <String>{};
    if (rawValue == null) { return selections; }
    final validOptionsSet = validOptions.toSet();
    bool hasUnknowns = false;
    List<String> valuesToProcess = [];
    if (rawValue is String) { valuesToProcess = [rawValue]; } 
    else if (rawValue is List) { valuesToProcess = rawValue.map((e) => e.toString()).toList(); }
    for (final value in valuesToProcess) {
      if (validOptionsSet.contains(value)) { selections.add(value); } 
      else { hasUnknowns = true; }
    }
    if (hasUnknowns && validOptionsSet.contains('Khác')) { selections.add('Khác'); }
    return selections;
  }
  Future<void> analyzeAllImages(List<XFile> images) async {
    state = state.copyWith(isLoading: true, clearAnalysisError: true);
    final useCase = _ref.read(analyzeItemUseCaseProvider);
    final analysisTasks = images.map((image) => useCase.execute(image)).toList();
    try {
      final results = await Future.wait(analysisTasks);
      final List<ItemNotifierArgs> itemArgsList = [];
      for (int i = 0; i < images.length; i++) {
        final result = results[i];
        final imageFile = images[i];
        final tempId = const Uuid().v4();
        
        // <<< SỬA LOGIC Ở ĐÂY >>>
        final preAnalyzedState = AddItemState(
          id: tempId, name: result['name'] as String? ?? '', image: File(imageFile.path),
          selectedCategoryValue: _normalizeCategory(result['category'] as String?),
          selectedColors: _normalizeColors(result['colors'] as List<dynamic>?),
          selectedMaterials: _normalizeMultiSelect(result['material'], AppOptions.materials.map((e) => e.name).toList()),
          selectedPatterns: _normalizeMultiSelect(result['pattern'], AppOptions.patterns.map((e) => e.name).toList()),
        );
        final args = ItemNotifierArgs(tempId: tempId, preAnalyzedState: preAnalyzedState);
        itemArgsList.add(args);
        _ref.read(addItemProvider(args));
      }
      state = state.copyWith(isLoading: false, itemArgsList: itemArgsList, analysisSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, analysisErrorMessage: e.toString());
    }
  }
  
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index, clearSaveError: true);
  }

  void nextPage() {
    final currentItemArgs = state.itemArgsList[state.currentIndex];
    final currentItemState = _ref.read(addItemProvider(currentItemArgs));
    
    final validationResult = _ref.read(validateRequiredFieldsUseCaseProvider).executeForSingle(currentItemState);

    if (validationResult.success) {
      if (state.currentIndex < state.itemArgsList.length - 1) {
        state = state.copyWith(
          currentIndex: state.currentIndex + 1,
          clearSaveError: true 
        );
      }
    } else {
      state = state.copyWith(saveErrorMessage: validationResult.errorMessage);
    }
  }

  void previousPage() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        clearSaveError: true
      );
    }
  }

  Future<void> saveAll() async {
    state = state.copyWith(isSaving: true, clearSaveError: true);
    final List<AddItemState> itemStates = state.itemArgsList.map((args) => _ref.read(addItemProvider(args))).toList();
    final validateRequiredUseCase = _ref.read(validateRequiredFieldsUseCaseProvider);
    final requiredResult = validateRequiredUseCase.executeForBatch(itemStates);
    if (!requiredResult.success) {
      state = state.copyWith(isSaving: false, saveErrorMessage: requiredResult.errorMessage, currentIndex: requiredResult.errorIndex);
      return;
    }
    final validateNameUseCase = _ref.read(validateItemNameUseCaseProvider);
    final nameValidationResult = await validateNameUseCase.forBatch(itemStates);
    if (!nameValidationResult.success) {
      state = state.copyWith(isSaving: false, saveErrorMessage: nameValidationResult.errorMessage, currentIndex: nameValidationResult.errorIndex);
      return;
    }
    final List<ClothingItem> itemsToSave = itemStates.map((itemState) {
      return ClothingItem(
        id: const Uuid().v4(), name: itemState.name.trim(), category: itemState.selectedCategoryValue,
        closetId: itemState.selectedClosetId!, imagePath: itemState.image!.path, color: itemState.selectedColors.join(', '),
        season: itemState.selectedSeasons.join(', '), occasion: itemState.selectedOccasions.join(', '),
        material: itemState.selectedMaterials.join(', '), pattern: itemState.selectedPatterns.join(', '),
      );
    }).toList();
    try {
      await _clothingItemRepo.insertBatchItems(itemsToSave);
      state = state.copyWith(isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, saveErrorMessage: "Lỗi khi lưu: $e");
    }
  }
}

final batchAddItemProvider = StateNotifierProvider.autoDispose<BatchAddItemNotifier, BatchAddItemState>((ref) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return BatchAddItemNotifier(repo, ref);
});