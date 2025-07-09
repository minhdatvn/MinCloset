// lib/notifiers/add_item_notifier.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/helpers/image_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/repositories/quest_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ItemNotifierArgs extends Equatable {
  final String tempId;
  final ClothingItem? itemToEdit;
  final AddItemState? preAnalyzedState;

  const ItemNotifierArgs({
    required this.tempId,
    this.itemToEdit,
    this.preAnalyzedState,
  });

  @override
  List<Object?> get props => [tempId];
}

class AddItemNotifier extends StateNotifier<AddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final QuestRepository _questRepo;
  final ImageHelper _imageHelper;
  final AnalyzeItemUseCase _analyzeItemUseCase;
  final ValidateRequiredFieldsUseCase _validateRequiredUseCase;
  final ValidateItemNameUseCase _validateNameUseCase;
  final Ref _ref;

  AddItemNotifier(
    this._clothingItemRepo,
    this._questRepo,
    this._imageHelper,
    this._analyzeItemUseCase,
    this._validateRequiredUseCase,
    this._validateNameUseCase,
    this._ref,
    ItemNotifierArgs args,
  ) : super(
          args.preAnalyzedState ??
          (args.itemToEdit != null
              ? AddItemState.fromClothingItem(args.itemToEdit!)
              : AddItemState(id: args.tempId))
        );

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
  void onPriceChanged(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), ''); // Loại bỏ tất cả các ký tự không phải là số
    state = state.copyWith(price: double.tryParse(cleanValue));
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

  Future<void> analyzeImage(XFile image) async {
    state = state.copyWith(isAnalyzing: true);
    final resultEither = await _analyzeItemUseCase.execute(image);

    if (!mounted) return;

    resultEither.fold(
      // (l) => Left: Xử lý khi có lỗi
      (failure) {
        // Gọi service để hiển thị banner lỗi cho người dùng
        _ref.read(notificationServiceProvider).showBanner(
          message: "Pre-filling information failed.\nReason: ${failure.message}"
        );
        state = state.copyWith(isAnalyzing: false);
      },
      // (r) => Right: Xử lý khi thành công
      (result) {
        final category = _normalizeCategory(result['category'] as String?);
        final colors = _normalizeColors(result['colors'] as List<dynamic>?);
        final materials = _normalizeMultiSelect(result['material'], AppOptions.materials.map((e) => e.name).toList());
        final patterns = _normalizeMultiSelect(result['pattern'], AppOptions.patterns.map((e) => e.name).toList());
        
        state = state.copyWith(
          isAnalyzing: false, 
          name: result['name'] as String? ?? state.name, 
          selectedCategoryValue: category, 
          selectedColors: colors, 
          selectedMaterials: materials.isNotEmpty ? materials : state.selectedMaterials, 
          selectedPatterns: patterns.isNotEmpty ? patterns : state.selectedPatterns
        );
      }
    );
  }

  void toggleFavorite() {
    // 1. Cập nhật UI ngay lập tức để người dùng thấy phản hồi
    final newFavoriteState = !state.isFavorite;
    state = state.copyWith(isFavorite: newFavoriteState);

    // 2. Tạo một đối tượng ClothingItem hoàn chỉnh từ trạng thái hiện tại
    // để chuẩn bị cho việc lưu vào database.
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

    // 3. Gọi repository để cập nhật item trong cơ sở dữ liệu.
    // Chúng ta không cần `await` ở đây vì đã cập nhật UI ở trên (Optimistic Update)
    // và không cần đợi kết quả để làm gì tiếp theo trong hàm này.
    _clothingItemRepo.updateItem(itemToUpdate);
  }
  
  Future<bool> saveItem() async {
    final sourceImagePath = state.image?.path ?? state.imagePath;
    if (sourceImagePath == null) {
      state = state.copyWith(errorMessage: 'Please add a photo for the item.');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);

    // --- BƯỚC 1: ĐỊNH NGHĨA CÁC BƯỚC XỬ LÝ ---

    Either<Failure, void> validateRequiredFields() {
      final result = _validateRequiredUseCase.executeForSingle(state);
      return result.success ? const Right(null) : Left(GenericFailure(result.errorMessage!));
    }

    TaskEither<Failure, ValidationResult> performNameValidation() {
      return TaskEither(() => _validateNameUseCase.forSingleItem(
            name: state.name,
            existingId: state.isEditing ? state.id : null,
      ));
    }

    TaskEither<Failure, String?> createThumbnail() {
      return TaskEither.tryCatch(
        // SỬA LỖI Ở ĐÂY: Bọc giá trị không phải Future bằng Future.value()
        () => state.image != null
            ? _imageHelper.createThumbnail(sourceImagePath)
            : Future.value(state.thumbnailPath),
        (error, stackTrace) => GenericFailure('Error creating thumbnail: $error'),
      );
    }
    
    TaskEither<Failure, void> saveToDatabase(String? thumbnailPath) {
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
    }

    // --- BƯỚC 2: XÂU CHUỖI CÁC BƯỚC LẠI ---
    final task = TaskEither.fromEither(validateRequiredFields())
        .flatMap((_) => performNameValidation())
        .flatMap((validationResult) {
          if (validationResult.success) {
            return TaskEither.right(null);
          }
          return TaskEither.left(GenericFailure(validationResult.errorMessage!));
        })
        .flatMap((_) => createThumbnail())
        .flatMap((thumbnailPath) => saveToDatabase(thumbnailPath));

    // --- BƯỚC 3: THỰC THI VÀ XỬ LÝ KẾT QUẢ ---
    final result = await task.run();

    if (!mounted) return false;

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) async { // <<< CHUYỂN THÀNH HÀM ASYNC >>>
        // Tạo lại đối tượng ClothingItem hoàn chỉnh đã được lưu
        final savedItem = ClothingItem(
            id: state.isEditing ? state.id : const Uuid().v4(),
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
            isFavorite: state.isFavorite,
            price: state.price,
            notes: state.notes,
        );

        // <<< GỌI HÀM CẬP NHẬT TIẾN TRÌNH NHIỆM VỤ >>>
        if (!state.isEditing) { // Chỉ cập nhật tiến trình khi thêm món đồ mới
            await _questRepo.updateQuestProgress(savedItem);
        }

        _ref.read(itemChangedTriggerProvider.notifier).state++;
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
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
        _ref.read(itemChangedTriggerProvider.notifier).state++;
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }

  Future<void> updateImageWithBytes(Uint8List imageBytes) async {
    try {
      // Tạo một file tạm thời từ dữ liệu bytes
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${const Uuid().v4()}.png');
      await tempFile.writeAsBytes(imageBytes);

      // Cập nhật state với file ảnh mới
      state = state.copyWith(image: tempFile);
    } catch (e) {
      _ref.read(notificationServiceProvider).showBanner(
        message: 'Không thể cập nhật ảnh: $e',
      );
    }
  }
}

/// Provider cho màn hình Thêm/Sửa MỘT vật phẩm.
/// Sẽ tự động hủy state khi rời khỏi màn hình.
final singleItemProvider = StateNotifierProvider
    .autoDispose
    .family<AddItemNotifier, AddItemState, ItemNotifierArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final questRepo = ref.watch(questRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  final analyzeItemUseCase = ref.watch(analyzeItemUseCaseProvider);
  final validateRequiredUseCase = ref.watch(validateRequiredFieldsUseCaseProvider);
  final validateNameUseCase = ref.watch(validateItemNameUseCaseProvider);
  
  return AddItemNotifier(
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
    .family<AddItemNotifier, AddItemState, ItemNotifierArgs>((ref, args) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final questRepo = ref.watch(questRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider);
  final analyzeItemUseCase = ref.watch(analyzeItemUseCaseProvider);
  final validateRequiredUseCase = ref.watch(validateRequiredFieldsUseCaseProvider);
  final validateNameUseCase = ref.watch(validateItemNameUseCaseProvider);
  
  return AddItemNotifier(
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