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
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mincloset/helpers/category_helper.dart';

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

  Future<void> analyzeImage(XFile image, {required AppLocalizations l10n}) async {
    state = state.copyWith(isAnalyzing: true);
    final resultEither = await _analyzeItemUseCase.execute(image);

    if (!mounted) return;

    resultEither.fold(
      (failure) {
        state = state.copyWith(
          isAnalyzing: false,
          errorMessage: l10n.itemNotifier_analysis_error(failure.message),
        );
      },
      (result) {
        // <<< SỬ DỤNG CÁC HÀM HELPER Ở ĐÂY >>>
        final category = normalizeCategory(result['category'] as String?);
        final colors = normalizeColors(result['colors'] as List<dynamic>?);
        final materials = normalizeMultiSelect(result['material'], 'material', AppOptions.materials.map((e) => e.name).toList());
        final patterns = normalizeMultiSelect(result['pattern'], 'pattern', AppOptions.patterns.map((e) => e.name).toList());

        state = state.copyWith(
          isAnalyzing: false,
          name: result['name'] as String? ?? state.name,
          selectedCategoryValue: category,
          selectedColors: colors,
          selectedMaterials: materials.isNotEmpty ? materials : state.selectedMaterials,
          selectedPatterns: patterns.isNotEmpty ? patterns : state.selectedPatterns,
        );
      },
    );
  }
  
  Future<void> saveItem({required AppLocalizations l10n}) async {
    // 1. Vẫn kiểm tra ảnh và các trường bắt buộc như cũ
    final sourceImagePath = state.image?.path ?? state.imagePath;
    if (sourceImagePath == null) {
      _ref.read(itemDetailErrorProvider.notifier).state = l10n.itemNotifier_error_noPhoto;
      return;
    }
    
    final requiredFieldsResult = _validateRequiredUseCase.executeForSingle(state);
    if (!requiredFieldsResult.success) {
      String errorMessage = 'Unknown required field error';
      switch (requiredFieldsResult.errorCode) {
        case 'name_required':
          errorMessage = l10n.validation_error_name_required;
          break;
        case 'closet_required':
          errorMessage = l10n.validation_error_closet_required;
          break;
        case 'category_required':
          errorMessage = l10n.validation_error_category_required;
          break;
      }
      _ref.read(itemDetailErrorProvider.notifier).state = errorMessage;
      return;
    }

    // Nếu không có lỗi, tiếp tục với logic xử lý bất đồng bộ
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    final task = TaskEither(
            () => _validateNameUseCase.forSingleItem(
                  name: state.name,
                  existingId: state.isEditing ? state.id : null,
                ))
        .flatMap((validationResult) {
          if (!validationResult.success) {
            // Nếu validation thất bại, xử lý lỗi tại đây
            String translatedErrorMessage = 'An unknown validation error occurred.'; // Lỗi mặc định
            final data = validationResult.data;

            // Kiểm tra mã lỗi và tạo thông báo đã dịch
            if (validationResult.errorCode == 'nameTakenSingle' && data != null) {
              translatedErrorMessage = l10n.validation_nameTakenSingle(data['itemName']);
            }
            // (Trong tương lai có thể thêm các case 'else if' cho các mã lỗi khác)

            // Gửi thông báo lỗi đã dịch đến UI thông qua provider riêng
            _ref.read(itemDetailErrorProvider.notifier).state = translatedErrorMessage;
            
            // Dừng chuỗi TaskEither bằng cách trả về Left
            return TaskEither.left(GenericFailure('Validation failed: ${validationResult.errorCode}'));
          }
          // Nếu validation thành công, tiếp tục chuỗi
          return TaskEither.right(unit);
        })
        .flatMap((_) => TaskEither.tryCatch(
              () => state.image != null
                  ? _imageHelper.createThumbnail(sourceImagePath)
                  : Future.value(state.thumbnailPath),
              (error, stackTrace) =>
                  GenericFailure(l10n.itemNotifier_error_createThumbnail(error.toString())),
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
      final saveFuture = state.isEditing
          ? _clothingItemRepo.updateItem(item)
          : _clothingItemRepo.insertItem(item);
      return TaskEither(() => saveFuture);
    });

    final result = await task.run();

    if (!mounted) return;

    // Logic xử lý kết quả cuối cùng không thay đổi
    result.fold(
      (failure) {
        // Nếu chuỗi tác vụ nặng thất bại, chúng ta vẫn dùng state để báo lỗi
        // vì đây là lỗi hệ thống, không phải lỗi nhập liệu.
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) async {
        if (!state.isEditing) {
            final mainCategory = state.selectedCategoryValue.split(' > ').first.trim();
            QuestEvent? event;
            if (mainCategory == 'category_tops') {
              event = QuestEvent.topAdded;
            } else if (mainCategory == 'category_bottoms' || mainCategory == 'category_dresses_jumpsuits') {
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
          successMessage: state.isEditing ? l10n.itemNotifier_save_success_updated : l10n.itemNotifier_save_success_created
        );
      },
    );
  }

  Future<void> deleteItem({required AppLocalizations l10n}) async {
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
          successMessage: l10n.itemNotifier_delete_success(state.name)
        );
      },
    );
  }

  Future<void> updateImageWithBytes(Uint8List imageBytes, {required AppLocalizations l10n}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${const Uuid().v4()}.png');
      await tempFile.writeAsBytes(imageBytes);

      state = state.copyWith(image: tempFile);
    } catch (e) {
      state = state.copyWith(errorMessage: l10n.itemNotifier_error_updateImage(e.toString()));
    }
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

  Future<void> pickImage(ImageSource source, {required AppLocalizations l10n}) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (pickedFile != null) {
      state = state.copyWith(image: File(pickedFile.path), selectedCategoryValue: '', selectedColors: {}, selectedMaterials: {}, selectedPatterns: {});
    analyzeImage(pickedFile, l10n: l10n);
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