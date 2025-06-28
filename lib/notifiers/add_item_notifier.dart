// lib/notifiers/add_item_notifier.dart

import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/helpers/image_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/add_item_state.dart';

class ItemNotifierArgs extends Equatable {
  final String tempId;
  final ClothingItem? itemToEdit;
  final XFile? newImage;
  final AddItemState? preAnalyzedState;

  const ItemNotifierArgs({
    required this.tempId,
    this.itemToEdit,
    this.newImage,
    this.preAnalyzedState,
  });

  @override
  List<Object?> get props => [tempId];
}

class AddItemNotifier extends StateNotifier<AddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final ImageHelper _imageHelper;
  final AnalyzeItemUseCase _analyzeItemUseCase;
  final ValidateRequiredFieldsUseCase _validateRequiredUseCase;
  final ValidateItemNameUseCase _validateNameUseCase;
  // <<< THAY ĐỔI 1: Xóa 'final Ref _ref;' >>>

  AddItemNotifier(
    this._clothingItemRepo,
    this._imageHelper,
    this._analyzeItemUseCase,
    this._validateRequiredUseCase,
    this._validateNameUseCase,
    // <<< THAY ĐỔI 2: Xóa 'this._ref' khỏi constructor >>>
    ItemNotifierArgs args,
  ) : super(
          args.preAnalyzedState ??
          (args.itemToEdit != null
              ? AddItemState.fromClothingItem(args.itemToEdit!)
              : AddItemState(
                  id: args.tempId,
                  image: args.newImage != null ? File(args.newImage!.path) : null
                ))
        ) {
    if (args.preAnalyzedState == null && args.newImage != null) {
      analyzeImage(args.newImage!);
    }
  }

  // Toàn bộ logic bên trong các hàm không thay đổi vì đã dùng dependency trực tiếp
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

  void onNameChanged(String name) => state = state.copyWith(name: name);
  void onClosetChanged(String? closetId) => state = state.copyWith(selectedClosetId: closetId);
  void onCategoryChanged(String category) => state = state.copyWith(selectedCategoryValue: category);
  void onColorsChanged(Set<String> colors) => state = state.copyWith(selectedColors: colors);
  void onSeasonsChanged(Set<String> seasons) => state = state.copyWith(selectedSeasons: seasons);
  void onOccasionsChanged(Set<String> occasions) => state = state.copyWith(selectedOccasions: occasions);
  void onMaterialsChanged(Set<String> materials) => state = state.copyWith(selectedMaterials: materials);
  void onPatternsChanged(Set<String> patterns) => state = state.copyWith(selectedPatterns: patterns);
  
  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (pickedFile != null) {
      state = state.copyWith(image: File(pickedFile.path), selectedCategoryValue: '', selectedColors: {}, selectedMaterials: {}, selectedPatterns: {});
      analyzeImage(pickedFile);
    }
  }

  Future<void> analyzeImage(XFile image) async {
    state = state.copyWith(isAnalyzing: true);
    final result = await _analyzeItemUseCase.execute(image);
    if (result.isNotEmpty && mounted) {
      final category = _normalizeCategory(result['category'] as String?);
      final colors = _normalizeColors(result['colors'] as List<dynamic>?);
      final materials = _normalizeMultiSelect(result['material'], AppOptions.materials.map((e) => e.name).toList());
      final patterns = _normalizeMultiSelect(result['pattern'], AppOptions.patterns.map((e) => e.name).toList());
      state = state.copyWith(isAnalyzing: false, name: result['name'] as String? ?? state.name, selectedCategoryValue: category, selectedColors: colors, selectedMaterials: materials.isNotEmpty ? materials : state.selectedMaterials, selectedPatterns: patterns.isNotEmpty ? patterns : state.selectedPatterns);
    } else if (mounted) {
      state = state.copyWith(isAnalyzing: false);
    }
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  Future<bool> saveItem() async {
    final sourceImagePath = state.image?.path ?? state.imagePath;
    if (sourceImagePath == null) {
      state = state.copyWith(errorMessage: 'Please add a photo for the item.');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);

    final requiredResult = _validateRequiredUseCase.executeForSingle(state);
    if (!requiredResult.success) {
      state = state.copyWith(isLoading: false, errorMessage: requiredResult.errorMessage);
      return false;
    }

    final nameValidationEither = await _validateNameUseCase.forSingleItem(
      name: state.name,
      existingId: state.isEditing ? state.id : null,
    );
    
    return await nameValidationEither.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (nameValidationResult) async {
        if (!nameValidationResult.success) {
          state = state.copyWith(isLoading: false, errorMessage: nameValidationResult.errorMessage);
          return false;
        }

        final String? thumbnailPath = state.image != null
            ? await _imageHelper.createThumbnail(sourceImagePath)
            : null;
        
        final clothingItem = ClothingItem(
          id: state.isEditing ? state.id : const Uuid().v4(),
          name: state.name.trim(),
          category: state.selectedCategoryValue,
          closetId: state.selectedClosetId!,
          imagePath: sourceImagePath,
          thumbnailPath: thumbnailPath ?? state.thumbnailPath,
          color: state.selectedColors.join(', '),
          season: state.selectedSeasons.join(', '),
          occasion: state.selectedOccasions.join(', '),
          material: state.selectedMaterials.join(', '),
          pattern: state.selectedPatterns.join(', '),
          isFavorite: state.isFavorite,
        );

        final result = state.isEditing
            ? await _clothingItemRepo.updateItem(clothingItem)
            : await _clothingItemRepo.insertItem(clothingItem);

        if (!mounted) return false;

        return result.fold(
          (failure) {
            state = state.copyWith(isLoading: false, errorMessage: failure.message);
            return false;
          },
          (_) {
            state = state.copyWith(isLoading: false, isSuccess: true);
            return true;
          },
        );
      },
    );
  }

  Future<bool> deleteItem() async {
    if (!state.isEditing) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    await _imageHelper.deleteImageAndThumbnail(
      imagePath: state.imagePath,
      thumbnailPath: state.thumbnailPath,
    );

    final result = await _clothingItemRepo.deleteItem(state.id);
    
    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }
}

final addItemProvider = StateNotifierProvider
    .family<AddItemNotifier, AddItemState, ItemNotifierArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  final analyzeItemUseCase = ref.watch(analyzeItemUseCaseProvider);
  final validateRequiredUseCase = ref.watch(validateRequiredFieldsUseCaseProvider);
  final validateNameUseCase = ref.watch(validateItemNameUseCaseProvider);
  
  return AddItemNotifier(
    clothingItemRepo,
    imageHelper,
    analyzeItemUseCase,
    validateRequiredUseCase,
    validateNameUseCase,
    // <<< THAY ĐỔI 3: Xóa 'ref' khỏi danh sách đối số >>>
    args,
  );
});