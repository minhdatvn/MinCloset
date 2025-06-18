// lib/notifiers/add_item_notifier.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/providers.dart'; // <<< THÊM IMPORT ĐỂ GỌI USECASE
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:uuid/uuid.dart';

class AddItemNotifier extends StateNotifier<AddItemState> {
  final ClothingItemRepository _clothingItemRepo;
  final Ref _ref; // <<< THÊM REF ĐỂ CÓ THỂ GỌI CÁC PROVIDER KHÁC

  // <<< CẬP NHẬT HÀM KHỞI TẠO
  AddItemNotifier(this._clothingItemRepo, this._ref, AddItemScreenArgs args)
      : super(
          args.itemToEdit != null
              ? AddItemState.fromClothingItem(args.itemToEdit!)
              : AddItemState(image: args.newImage != null ? File(args.newImage!.path) : null)
        ) {
    // Tự động phân tích ảnh khi khởi tạo nếu là ảnh mới
    if (args.newImage != null) {
      analyzeImage(args.newImage!);
    }
  }

  // ... các hàm on...Changed giữ nguyên ...
  void onNameChanged(String name) => state = state.copyWith(name: name);
  void onClosetChanged(String? closetId) => state = state.copyWith(selectedClosetId: closetId);
  void onCategoryChanged(String category) => state = state.copyWith(selectedCategoryValue: category);
  void onColorsChanged(Set<String> colors) => state = state.copyWith(selectedColors: colors);
  void onSeasonsChanged(Set<String> seasons) => state = state.copyWith(selectedSeasons: seasons);
  void onOccasionsChanged(Set<String> occasions) => state = state.copyWith(selectedOccasions: occasions);
  void onMaterialsChanged(Set<String> materials) => state = state.copyWith(selectedMaterials: materials);
  void onPatternsChanged(Set<String> patterns) => state = state.copyWith(selectedPatterns: patterns);
  
  // <<< CẬP NHẬT HÀM PICKIMAGE ĐỂ GỌI PHÂN TÍCH
  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      state = state.copyWith(image: File(pickedFile.path));
      // Tự động phân tích sau khi chọn ảnh thành công
      analyzeImage(pickedFile); 
    }
  }

  // <<< HÀM MỚI ĐỂ GỌI AI
  Future<void> analyzeImage(XFile image) async {
    state = state.copyWith(isAnalyzing: true);
    final useCase = _ref.read(analyzeItemUseCaseProvider);
    final result = await useCase.execute(image);

    if (result.isNotEmpty && mounted) {
      // Phân tích kết quả trả về từ AI
      final category = result['category'] as String?;
      final colors = (result['colors'] as List<dynamic>?)?.map((e) => e.toString()).toSet();
      final material = (result['material'] as String?) != null ? {result['material'] as String} : null;
      final pattern = (result['pattern'] as String?) != null ? {result['pattern'] as String} : null;

      // Cập nhật state với các giá trị được phân tích
      state = state.copyWith(
        isAnalyzing: false,
        selectedCategoryValue: category ?? state.selectedCategoryValue,
        selectedColors: colors ?? state.selectedColors,
        selectedMaterials: material ?? state.selectedMaterials,
        selectedPatterns: pattern ?? state.selectedPatterns,
      );
    } else if (mounted) {
      // Nếu AI không trả về kết quả hoặc có lỗi, tắt trạng thái analyzing
      state = state.copyWith(isAnalyzing: false);
    }
  }
  
  // Hàm saveItem và deleteItem giữ nguyên
  Future<void> saveItem() async {
    if (state.image == null && state.imagePath == null) {
      state = state.copyWith(errorMessage: 'Vui lòng thêm ảnh cho món đồ.');
      return;
    }
    if (state.name.trim().isEmpty) {
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
    
    final clothingItem = ClothingItem(
      id: state.isEditing ? state.id : const Uuid().v4(),
      name: state.name,
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