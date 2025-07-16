// lib/notifiers/add_item_notifier.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/helpers/image_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/quest_repository.dart';
import 'package:mincloset/states/item_detail_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ItemDetailNotifierArgs extends Equatable {
  final String tempId;
  final ClothingItem? itemToEdit;
  final ItemDetailState? preAnalyzedState;

  const ItemDetailNotifierArgs({
    required this.tempId,
    this.itemToEdit,
    this.preAnalyzedState,
  });

  @override
  List<Object?> get props => [tempId];
}

class ItemDetailNotifier extends StateNotifier<ItemDetailState> {
  final ClothingItemRepository _clothingItemRepo;
  final QuestRepository _questRepo;
  final ImageHelper _imageHelper;
  final AnalyzeItemUseCase _analyzeItemUseCase;
  final ValidateRequiredFieldsUseCase _validateRequiredUseCase;
  final ValidateItemNameUseCase _validateNameUseCase;
  final Ref _ref;

  ItemDetailNotifier(
    this._clothingItemRepo,
    this._questRepo,
    this._imageHelper,
    this._analyzeItemUseCase,
    this._validateRequiredUseCase,
    this._validateNameUseCase,
    this._ref,
    ItemDetailNotifierArgs args,
  ) : super(
          args.preAnalyzedState ??
          (args.itemToEdit != null
              ? ItemDetailState.fromClothingItem(args.itemToEdit!)
              : ItemDetailState(id: args.tempId))
        );
  
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  Future<void> analyzeImage(XFile image) async {
    state = state.copyWith(isAnalyzing: true);
    final resultEither = await _analyzeItemUseCase.execute(image);

    if (!mounted) return;

    resultEither.fold(
      (failure) {
        state = state.copyWith(
          isAnalyzing: false,
          errorMessage:
              "Pre-filling information failed.\nReason: ${failure.message}",
        );
      },
      (result) {
        final category = _normalizeCategory(result['category'] as String?);
        final colors = _normalizeColors(result['colors'] as List<dynamic>?);
        final materials = _normalizeMultiSelect(result['material'], 'material',
            AppOptions.materials.map((e) => e.name).toList());
        final patterns = _normalizeMultiSelect(result['pattern'], 'pattern',
            AppOptions.patterns.map((e) => e.name).toList());

        state = state.copyWith(
          isAnalyzing: false,
          name: result['name'] as String? ?? state.name,
          selectedCategoryValue: category,
          selectedColors: colors,
          selectedMaterials:
              materials.isNotEmpty ? materials : state.selectedMaterials,
          selectedPatterns:
              patterns.isNotEmpty ? patterns : state.selectedPatterns,
        );
      },
    );
  }
  
  // <<< BẮT ĐẦU SỬA LỖI TẠI ĐÂY >>>
  Future<void> saveItem() async {
    final sourceImagePath = state.image?.path ?? state.imagePath;
    if (sourceImagePath == null) {
      state = state.copyWith(errorMessage: 'Please add a photo for the item.');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    // 1. Khai báo kiểu là Either<Failure, Unit> thay vì Either<Failure, void>
    final Either<Failure, Unit> initialValidation;
    final requiredFieldsResult = _validateRequiredUseCase.executeForSingle(state);

    if (requiredFieldsResult.success) {
      // Dùng const Right(unit) của fpdart
      initialValidation = const Right(unit);
    } else {
      initialValidation = Left(GenericFailure(requiredFieldsResult.errorMessage!));
    }
    
    final task = TaskEither.fromEither(initialValidation)
        .flatMap((_) => TaskEither(() => _validateNameUseCase.forSingleItem(
              name: state.name,
              existingId: state.isEditing ? state.id : null,
            )))
        .flatMap((validationResult) => validationResult.success
            ? TaskEither.right(unit) // Dùng TaskEither.right(unit)
            : TaskEither.left(GenericFailure(validationResult.errorMessage!)))
        .flatMap((_) => TaskEither.tryCatch(
              () => state.image != null
                  ? _imageHelper.createThumbnail(sourceImagePath)
                  : Future.value(state.thumbnailPath),
              (error, stackTrace) => GenericFailure('Error creating thumbnail: $error'),
            ))
        .flatMap((thumbnailPath) {
          final item = ClothingItem(
            id: state.isEditing ? state.id : const Uuid().v4(),
            name: state.name.trim(),
            category: state.selectedCategoryValue,
            closetId: state.selectedClosetId!,
            imagePath: sourceImagePath,
            thumbnailPath: thumbnailPath,
            color: state.selectedColors.join(', '),
            season: state.selectedSeasons.join(', '),
            occasion: state.selectedOccasions.join(', '),
            material: state.selectedMaterials.join(', '),
            pattern: state.selectedPatterns.join(', '),
            isFavorite: state.isFavorite,
            price: state.price,
            notes: state.notes,
          );
          final saveFuture = state.isEditing ? _clothingItemRepo.updateItem(item) : _clothingItemRepo.insertItem(item);
          return TaskEither(() => saveFuture);
        });

    final result = await task.run();

    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) async {
        if (!state.isEditing) {
            final mainCategory = state.selectedCategoryValue.split(' > ').first.trim();
            QuestEvent? event;
            if (mainCategory == 'Tops') {
              event = QuestEvent.topAdded;
            } else if (mainCategory == 'Bottoms' || mainCategory == 'Dresses/Jumpsuits') {
              event = QuestEvent.bottomAdded;
            }

            if (event != null) {
              final completedQuests = await _questRepo.updateQuestProgress(event);
              if (completedQuests.isNotEmpty && mounted) {
                _ref.read(completedQuestProvider.notifier).state = completedQuests.first;
              }
            }
        }

        _ref.read(itemChangedTriggerProvider.notifier).state++;
        state = state.copyWith(
          isLoading: false, 
          isSuccess: true,
          successMessage: state.isEditing ? 'Item successfully updated.' : 'Item successfully saved.'
        );
      },
    );
  }

  Future<void> deleteItem() async {
    if (!state.isEditing) return;
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    await _imageHelper.deleteImageAndThumbnail(
      imagePath: state.imagePath,
      thumbnailPath: state.thumbnailPath,
    );

    final result = await _clothingItemRepo.deleteItem(state.id);
    
    if (!mounted) return;

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        _ref.read(itemChangedTriggerProvider.notifier).state++;
        state = state.copyWith(
          isLoading: false, 
          isSuccess: true,
          successMessage: 'Successfully deleted item "${state.name}".'
        );
      },
    );
  }

  Future<void> updateImageWithBytes(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${const Uuid().v4()}.png');
      await tempFile.writeAsBytes(imageBytes);

      state = state.copyWith(image: tempFile);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not update image: $e');
    }
  }
  
  // --- Các hàm còn lại giữ nguyên, không cần thay đổi ---
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

  String _createLocalizationKey(String base, String value) {
    return '${base}_${value.toLowerCase().replaceAll(' ', '_').replaceAll('/', '_')}';
  }

  // --- HÀM ĐƯỢC CẬP NHẬT ---
  String _normalizeCategory(String? rawCategory) {
    if (rawCategory == null || rawCategory.trim().isEmpty) {
      return 'category_other';
    }

    final parts = rawCategory.split(' > ').map((p) => p.trim()).toList();
    final mainCategoryText = parts.first;

    // Nếu danh mục chính là "Other" hoặc "Khác" (bất kể có danh mục con hay không)
    // thì coi đó là danh mục "Khác" cấp 1
    if (mainCategoryText.toLowerCase() == 'other' || mainCategoryText.toLowerCase() == 'khác') {
      return 'category_other';
    }

    final mainCategoryKey = _createLocalizationKey('category', mainCategoryText);

    // Nếu không nhận dạng được danh mục chính
    if (!AppOptions.categories.containsKey(mainCategoryKey)) {
      return 'category_other';
    }

    // Nếu chỉ có 1 phần tử, hoặc phần tử thứ 2 là "Other"/"Khác"
    if (parts.length == 1 || parts[1].toLowerCase() == 'other' || parts[1].toLowerCase() == 'khác') {
      // Trả về dạng "danh_muc_chinh > danh_muc_chinh_other"
      return '$mainCategoryKey > ${mainCategoryKey}_other';
    }

    // Xử lý trường hợp "danh mục chính > danh mục con" thông thường
    final subCategoryText = parts[1];
    final subCategoryKey = _createLocalizationKey(mainCategoryKey, subCategoryText);

    if (AppOptions.categories[mainCategoryKey]?.contains(subCategoryKey) ?? false) {
      return '$mainCategoryKey > $subCategoryKey';
    }

    // Nếu không tìm thấy, trả về danh mục chính với con là "other"
    return '$mainCategoryKey > ${mainCategoryKey}_other';
  }

  Set<String> _normalizeMultiSelect(
      dynamic rawValue, String baseKey, List<String> validOptionKeys) {
    final selections = <String>{};
    if (rawValue == null) return selections;

    final validOptionsSet = validOptionKeys.toSet();
    List<String> valuesToProcess = [];

    if (rawValue is String) {
      valuesToProcess = [rawValue];
    } else if (rawValue is List) {
      valuesToProcess = rawValue.map((e) => e.toString()).toList();
    }

    for (final value in valuesToProcess) {
      // Sửa lỗi: Nhận diện cả 'Other' và 'Khác'
      if (value.toLowerCase() == 'other' || value.toLowerCase() == 'khác') {
        selections.add('${baseKey}_other');
        continue;
      }

      final optionKey = _createLocalizationKey(baseKey, value);
      if (validOptionsSet.contains(optionKey)) {
        selections.add(optionKey);
      }
    }

    if (selections.isEmpty && valuesToProcess.isNotEmpty) {
      final otherKey = '${baseKey}_other';
      if (validOptionsSet.contains(otherKey)) {
        selections.add(otherKey);
      }
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
  void onPriceChanged(String value) {
    if (value.isEmpty) {
      state = state.copyWith(price: null);
      return;
    }
    final formatType = _ref.read(profileProvider).numberFormat; // 1. Đọc cài đặt định dạng số của người dùng
    String cleanValue;
    if (formatType == NumberFormatType.commaDecimal) {
      cleanValue = value.replaceAll(RegExp(r'\.'), '').replaceAll(',', '.'); // Định dạng 1.000,00 -> Thay thế dấu phẩy thập phân bằng dấu chấm
    } else {
      cleanValue = value.replaceAll(RegExp(r','), ''); // Định dạng 1,000.00 -> Chỉ cần xóa dấu phẩy
    }    
    state = state.copyWith(price: double.tryParse(cleanValue)); // 2. Chuyển đổi chuỗi đã được làm sạch thành double
  }

  void onNotesChanged(String value) {state = state.copyWith(notes: value);}
  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (pickedFile != null) {
      state = state.copyWith(image: File(pickedFile.path), selectedCategoryValue: '', selectedColors: {}, selectedMaterials: {}, selectedPatterns: {});
      analyzeImage(pickedFile);
    }
  }
  void toggleFavorite() {
    final newFavoriteState = !state.isFavorite;
    state = state.copyWith(isFavorite: newFavoriteState);
    final itemToUpdate = ClothingItem(
      id: state.id,
      name: state.name.trim(),
      category: state.selectedCategoryValue,
      closetId: state.selectedClosetId!,
      imagePath: state.image?.path ?? state.imagePath!,
      thumbnailPath: state.thumbnailPath,
      color: state.selectedColors.join(', '),
      season: state.selectedSeasons.join(', '),
      occasion: state.selectedOccasions.join(', '),
      material: state.selectedMaterials.join(', '),
      pattern: state.selectedPatterns.join(', '),
      isFavorite: newFavoriteState,
      price: state.price,
      notes: state.notes,
    );
    _clothingItemRepo.updateItem(itemToUpdate);
  }
}

/// Provider cho màn hình Thêm/Sửa MỘT vật phẩm.
/// Sẽ tự động hủy state khi rời khỏi màn hình.
final itemDetailProvider = StateNotifierProvider
    .autoDispose
    .family<ItemDetailNotifier, ItemDetailState, ItemDetailNotifierArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final questRepo = ref.watch(questRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  final analyzeItemUseCase = ref.watch(analyzeItemUseCaseProvider);
  final validateRequiredUseCase = ref.watch(validateRequiredFieldsUseCaseProvider);
  final validateNameUseCase = ref.watch(validateItemNameUseCaseProvider);
  
  return ItemDetailNotifier(
    clothingItemRepo,
    questRepo,
    imageHelper,
    analyzeItemUseCase,
    validateRequiredUseCase,
    validateNameUseCase,
    ref,
    args,
  );
});

/// Provider cho màn hình Thêm HÀNG LOẠT.
/// Sẽ GIỮ LẠI state khi người dùng vuốt qua lại giữa các item.
final batchItemFormProvider = StateNotifierProvider
    .family<ItemDetailNotifier, ItemDetailState, ItemDetailNotifierArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final questRepo = ref.watch(questRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  final analyzeItemUseCase = ref.watch(analyzeItemUseCaseProvider);
  final validateRequiredUseCase = ref.watch(validateRequiredFieldsUseCaseProvider);
  final validateNameUseCase = ref.watch(validateItemNameUseCaseProvider);
  
  return ItemDetailNotifier(
    clothingItemRepo,
    questRepo,
    imageHelper,
    analyzeItemUseCase,
    validateRequiredUseCase,
    validateNameUseCase,
    ref,
    args,
  );
});