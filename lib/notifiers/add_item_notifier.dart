// lib/notifiers/add_item_notifier.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:uuid/uuid.dart';

class AddItemNotifier extends StateNotifier<AddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final Ref _ref;
  // <<< SỬA LỖI: XÓA BỎ TRƯỜNG `_originalName` KHÔNG SỬ DỤNG >>>

  AddItemNotifier(this._clothingItemRepo, this._ref, AddItemScreenArgs args)
      : super(
          args.preAnalyzedState ??
          (args.itemToEdit != null
              ? AddItemState.fromClothingItem(args.itemToEdit!)
              : AddItemState(image: args.newImage != null ? File(args.newImage!.path) : null))
        ) {
    if (args.preAnalyzedState == null && args.newImage != null) {
      analyzeImage(args.newImage!);
    }
  }
  
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
      state = state.copyWith(
        image: File(pickedFile.path),
        selectedCategoryValue: '',
        selectedColors: {},
        selectedMaterials: {},
        selectedPatterns: {},
      );
      analyzeImage(pickedFile); 
    }
  }

  Future<void> analyzeImage(XFile image) async {
    state = state.copyWith(isAnalyzing: true);
    final useCase = _ref.read(analyzeItemUseCaseProvider);
    final result = await useCase.execute(image);

    if (result.isNotEmpty && mounted) {
      final category = _normalizeCategory(result['category'] as String?);
      final colors = (result['colors'] as List<dynamic>?)?.map((e) => e.toString()).toSet();
      final materials = _normalizeMultiSelect(result['material'], AppOptions.materials.map((e) => e.name).toList());
      final patterns = _normalizeMultiSelect(result['pattern'], AppOptions.patterns.map((e) => e.name).toList());
      final suggestedName = result['name'] as String?;

      state = state.copyWith(
        isAnalyzing: false,
        name: suggestedName ?? state.name,
        selectedCategoryValue: category,
        selectedColors: colors ?? state.selectedColors,
        selectedMaterials: materials.isNotEmpty ? materials : state.selectedMaterials,
        selectedPatterns: patterns.isNotEmpty ? patterns : state.selectedPatterns,
      );
    } else if (mounted) {
      state = state.copyWith(isAnalyzing: false);
    }
  }
  
  Future<void> saveItem() async {
    if (state.image == null && state.imagePath == null) {
      state = state.copyWith(errorMessage: 'Vui lòng thêm ảnh cho món đồ.');
      return;
    }
    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập tên món đồ.');
      return;
    }
    if (state.selectedClosetId == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn tủ đồ.');
      return;
    }
    if (state.selectedCategoryValue.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn danh mục cho món đồ.');
      return;
    }
    
    state = state.copyWith(isLoading: true, errorMessage: null);

    final bool nameExists = await _clothingItemRepo.itemNameExists(
      trimmedName, 
      state.selectedClosetId!,
      currentItemId: state.isEditing ? state.id : null,
    );

    if (nameExists) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Tên "$trimmedName" đã được sử dụng. Bạn vui lòng chọn tên khác. Có thể thêm số vào sau tên (ví dụ: Áo 1, Áo 2,...) để dễ phân biệt'
      );
      return;
    }

    final clothingItem = ClothingItem(
      id: state.isEditing ? state.id : const Uuid().v4(),
      name: trimmedName,
      category: state.selectedCategoryValue,
      closetId: state.selectedClosetId!,
      imagePath: state.image?.path ?? state.imagePath!,
      color: state.selectedColors.join(', '),
      season: state.selectedSeasons.join(', '),
      occasion: state.selectedOccasions.join(', '),
      material: state.selectedMaterials.join(', '),
      pattern: state.selectedPatterns.join(', '),
    );

    try {
      if (state.isEditing) {
        await _clothingItemRepo.updateItem(clothingItem);
      } else {
        await _clothingItemRepo.insertItem(clothingItem);
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi khi lưu: $e');
    }
  }

  Future<void> deleteItem() async {
    if (!state.isEditing) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _clothingItemRepo.deleteItem(state.id);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi khi xóa: $e');
    }
  }
}