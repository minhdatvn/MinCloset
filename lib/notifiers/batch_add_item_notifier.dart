// lib/notifiers/batch_add_item_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/item_detail_state.dart';
import 'package:mincloset/states/batch_add_item_state.dart';
import 'package:uuid/uuid.dart';
import 'package:mincloset/repositories/quest_repository.dart';

class BatchAddItemNotifier extends StateNotifier<BatchItemDetailState> {
  final ClothingItemRepository _clothingItemRepo;
  final QuestRepository _questRepo;
  final AnalyzeItemUseCase _analyzeItemUseCase;
  final ValidateRequiredFieldsUseCase _validateRequiredUseCase;
  final ValidateItemNameUseCase _validateNameUseCase;
  final Ref _ref;

  // <<< THAY ĐỔI 2: Truyền dependencies vào constructor >>>
  BatchAddItemNotifier(
    this._clothingItemRepo,
    this._questRepo,
    this._analyzeItemUseCase,
    this._validateRequiredUseCase,
    this._validateNameUseCase,
    this._ref,
  ) : super(const BatchItemDetailState());

  // Các hàm helper và setCurrentIndex/nextPage/previousPage không thay đổi
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
    if (rawCategory == null || rawCategory.trim().isEmpty) { return 'Other > Other'; }
    if (!rawCategory.contains('>') && AppOptions.categories.containsKey(rawCategory)) { return '$rawCategory > Other'; }
    final parts = rawCategory.split(' > ');
    if (!AppOptions.categories.containsKey(parts.first)) { return 'Other > Other'; }
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
    if (hasUnknowns && validOptionsSet.contains('Other')) { selections.add('Other'); }
    return selections;
  }

  Future<void> analyzeAllImages(List<XFile> images) async {
    state = state.copyWith(
      isLoading: true,
      clearAnalysisError: true,
      stage: AnalysisStage.analyzing, // <-- Giữ nguyên để UI biết đang trong giai đoạn phân tích
      totalItemsToProcess: images.length,
      itemsProcessed: 0,
    );

    // 1. Tạo một danh sách các Future, mỗi Future là một yêu cầu phân tích ảnh
    final analysisFutures = images.map((image) {
      return _analyzeItemUseCase.execute(image);
    }).toList();

    // 2. Sử dụng Future.wait để thực hiện tất cả các yêu cầu song song.
    // Lệnh await này sẽ chỉ hoàn thành khi TẤT CẢ các yêu cầu trong list đã xong.
    final results = await Future.wait(analysisFutures);

    if (!mounted) return;

    final List<ItemDetailNotifierArgs> itemArgsList = [];
    
    // 3. Lặp qua danh sách kết quả (đã có đủ) để xử lý
    for (int i = 0; i < results.length; i++) {
      final resultEither = results[i];
      final image = images[i];

      resultEither.fold(
        (failure) {
          _ref.read(notificationServiceProvider).showBanner(
            message: "Pre-filling information failed.\nReason: ${failure.message}",
          );
          final tempId = const Uuid().v4();
          final preAnalyzedState = ItemDetailState(id: tempId, image: File(image.path));
          itemArgsList.add(ItemDetailNotifierArgs(tempId: tempId, preAnalyzedState: preAnalyzedState));
        },
        (result) {
          final tempId = const Uuid().v4();
          final preAnalyzedState = ItemDetailState(
            id: tempId, name: result['name'] as String? ?? '', image: File(image.path),
            selectedCategoryValue: _normalizeCategory(result['category'] as String?),
            selectedColors: _normalizeColors(result['colors'] as List<dynamic>?),
            selectedMaterials: _normalizeMultiSelect(result['material'], AppOptions.materials.map((e) => e.name).toList()),
            selectedPatterns: _normalizeMultiSelect(result['pattern'], AppOptions.patterns.map((e) => e.name).toList()),
          );
          itemArgsList.add(ItemDetailNotifierArgs(tempId: tempId, preAnalyzedState: preAnalyzedState));
        },
      );
    }
    
    // Khởi tạo các provider cho từng item
    for (final args in itemArgsList) {
        _ref.read(batchItemFormProvider(args));
    }

    if (mounted) {
      // Cập nhật state cuối cùng để điều hướng
      state = state.copyWith(
          isLoading: false, 
          itemArgsList: itemArgsList, 
          analysisSuccess: true, 
          itemsProcessed: images.length // <-- Đặt tiến độ là hoàn thành
      );
    }
  }
  
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index, clearSaveError: true);
  }

  void nextPage() {
    final currentItemArgs = state.itemArgsList[state.currentIndex];
    final currentItemState = _ref.read(batchItemFormProvider(currentItemArgs)); // Vẫn cần _ref
    
    // <<< THAY ĐỔI 4: Sử dụng trực tiếp UseCase đã được inject >>>
    final validationResult = _validateRequiredUseCase.executeForSingle(currentItemState);

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
    final itemStates = state.itemArgsList.map((args) => _ref.read(batchItemFormProvider(args))).toList(); // Vẫn cần _ref
    
    // <<< THAY ĐỔI 5: Sử dụng trực tiếp UseCase đã được inject >>>
    final requiredResult = _validateRequiredUseCase.executeForBatch(itemStates);
    if (!requiredResult.success) {
      state = state.copyWith(isSaving: false, saveErrorMessage: requiredResult.errorMessage, currentIndex: requiredResult.errorIndex);
      return;
    }
    
    // <<< THAY ĐỔI 6: Sử dụng trực tiếp UseCase đã được inject >>>
    final nameValidationEither = await _validateNameUseCase.forBatch(itemStates);

    if (!mounted) return;

    nameValidationEither.fold(
      (failure) {
        state = state.copyWith(isSaving: false, saveErrorMessage: failure.message);
      },
      (nameValidationResult) {
        if (!nameValidationResult.success) {
          state = state.copyWith(isSaving: false, saveErrorMessage: nameValidationResult.errorMessage, currentIndex: nameValidationResult.errorIndex);
          return;
        }
        _performSave(itemStates);
      },
    );
  }

  Future<void> _performSave(List<ItemDetailState> itemStates) async {
    final itemsToSave = itemStates.map((itemState) {
      return ClothingItem(
        id: const Uuid().v4(), name: itemState.name.trim(), category: itemState.selectedCategoryValue,
        closetId: itemState.selectedClosetId!, imagePath: itemState.image!.path, color: itemState.selectedColors.join(','),
        season: itemState.selectedSeasons.join(','), occasion: itemState.selectedOccasions.join(','),
        material: itemState.selectedMaterials.join(','), pattern: itemState.selectedPatterns.join(','),
      );
    }).toList();
    
    final result = await _clothingItemRepo.insertBatchItems(itemsToSave);
    
    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, saveErrorMessage: failure.message);
      },
      (_) async {
        Quest? lastCompletedQuest;

        for (final item in itemsToSave) {
            // THAY ĐỔI: Xác định loại sự kiện dựa trên category
            final mainCategory = item.category.split(' > ').first.trim();
            QuestEvent? event;
            if (mainCategory == 'Tops') {
              event = QuestEvent.topAdded;
            } else if (mainCategory == 'Bottoms' || mainCategory == 'Dresses/Jumpsuits') {
              event = QuestEvent.bottomAdded;
            }
            
            if (event != null) {
              final completedQuests = await _questRepo.updateQuestProgress(event);
              if (completedQuests.isNotEmpty) {
                lastCompletedQuest = completedQuests.last;
              }
            }
        }
        
        if (lastCompletedQuest != null && mounted) {
          _ref.read(completedQuestProvider.notifier).state = lastCompletedQuest;
        }

        _ref.read(itemChangedTriggerProvider.notifier).state++;
        state = state.copyWith(isSaving: false, saveSuccess: true);
      },
    );
  }
}

final batchAddScreenProvider = StateNotifierProvider.autoDispose<BatchAddItemNotifier, BatchItemDetailState>((ref) {
  // <<< THAY ĐỔI 7: Lấy tất cả dependency và truyền vào Notifier >>>
  final repo = ref.watch(clothingItemRepositoryProvider);
  final questRepo = ref.watch(questRepositoryProvider);
  final analyzeItemUseCase = ref.watch(analyzeItemUseCaseProvider);
  final validateRequiredUseCase = ref.watch(validateRequiredFieldsUseCaseProvider);
  final validateNameUseCase = ref.watch(validateItemNameUseCaseProvider);
  
  return BatchAddItemNotifier(
    repo,
    questRepo,
    analyzeItemUseCase,
    validateRequiredUseCase,
    validateNameUseCase,
    ref,
  );
});