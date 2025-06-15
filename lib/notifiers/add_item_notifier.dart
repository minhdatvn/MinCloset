// lib/notifiers/add_item_notifier.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:uuid/uuid.dart';

// <<< LỖI 1 ĐƯỢC SỬA TẠI ĐÂY: Thêm import này
import 'package:mincloset/providers/database_providers.dart';


class AddItemNotifier extends StateNotifier<AddItemState> {
  final DatabaseHelper _dbHelper;
  // <<< LỖI 2 ĐƯỢC SỬA TẠI ĐÂY: Xóa trường `_itemToEdit` không dùng đến

  // Tham số `itemToEdit` giờ được truyền trực tiếp vào constructor
  // mà không cần gán vào một trường của lớp.
  AddItemNotifier(this._dbHelper, ClothingItem? itemToEdit)
      : super(itemToEdit != null
              ? AddItemState.fromClothingItem(itemToEdit)
              : const AddItemState());

  // Các hàm để cập nhật từng phần của state từ UI
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
    final pickedImage = await imagePicker.pickImage(source: source, maxWidth: 600);
    if (pickedImage != null) {
      state = state.copyWith(image: File(pickedImage.path));
    }
  }

  Future<void> saveItem() async {
    // Validation
    if (state.name.trim().isEmpty || state.selectedCategoryValue.isEmpty || state.selectedClosetId == null || (state.image == null && state.imagePath == null)) {
        state = state.copyWith(errorMessage: 'Vui lòng điền đủ thông tin bắt buộc!');
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
        await _dbHelper.updateItem(clothingItem);
      } else {
        await _dbHelper.insertItem(clothingItem.toMap());
      }
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Lỗi khi lưu: $e');
    }
  }
}

// Provider này không thay đổi
final addItemProvider = StateNotifierProvider.autoDispose.family<AddItemNotifier, AddItemState, ClothingItem?>((ref, itemToEdit) {
  // <<< LỖI 1 ĐƯỢC SỬA TẠI ĐÂY: 
  // `dbHelperProvider` giờ đã được nhận diện nhờ câu lệnh import ở trên.
  final dbHelper = ref.watch(dbHelperProvider);
  return AddItemNotifier(dbHelper, itemToEdit);
});