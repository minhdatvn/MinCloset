// lib/notifiers/add_item_notifier.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:uuid/uuid.dart';

class AddItemNotifier extends StateNotifier<AddItemState> {
  final ClothingItemRepository _clothingItemRepo;

  AddItemNotifier(this._clothingItemRepo, ClothingItem? itemToEdit)
      : super(itemToEdit != null
              ? AddItemState.fromClothingItem(itemToEdit)
              : const AddItemState());

  // Các hàm onNameChanged, onClosetChanged, pickImage... giữ nguyên
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
    final pickedFile = await imagePicker.pickImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      state = state.copyWith(image: File(pickedFile.path));
    }
  }

  Future<void> saveItem() async {
    if (state.name.trim().isEmpty || state.selectedCategoryValue.isEmpty || state.selectedClosetId == null || (state.image == null && state.imagePath == null)) {
        state = state.copyWith(errorMessage: 'Vui lòng điền đủ thông tin bắt buộc!');
        return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // <<< LỖI NẰM Ở CÁCH BẠN GỌI HÀM KHỞI TẠO NÀY
    // Hãy đảm bảo bạn sử dụng đúng các tham số có tên (named parameters)
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
}

// Provider không thay đổi
final addItemProvider = StateNotifierProvider.autoDispose.family<AddItemNotifier, AddItemState, ClothingItem?>((ref, itemToEdit) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  return AddItemNotifier(clothingItemRepo, itemToEdit);
});