// lib/states/add_item_state.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

// Dùng @immutable để đảm bảo lớp này là bất biến
@immutable
class AddItemState {
  // Trạng thái của các trường trong form
  final String id;
  final String name;
  final File? image;
  final String? imagePath; // Dùng khi edit
  final String? selectedClosetId;
  final String selectedCategoryValue;
  final Set<String> selectedColors;
  final Set<String> selectedSeasons;
  final Set<String> selectedOccasions;
  final Set<String> selectedMaterials;
  final Set<String> selectedPatterns;

  // Trạng thái của UI
  final bool isLoading; // Dùng khi lưu
  final bool isEditing;
  final bool isAnalyzing; // <<< THÊM TRƯỜNG MỚI ĐỂ THEO DÕI TRẠNG THÁI CỦA AI
  final String? errorMessage;
  final bool isSuccess; // Cờ để báo hiệu lưu thành công

  const AddItemState({
    this.id = '',
    this.name = '',
    this.image,
    this.imagePath,
    this.selectedClosetId,
    this.selectedCategoryValue = '',
    this.selectedColors = const {},
    this.selectedSeasons = const {},
    this.selectedOccasions = const {},
    this.selectedMaterials = const {},
    this.selectedPatterns = const {},
    this.isLoading = false,
    this.isEditing = false,
    this.isAnalyzing = false, // <<< KHỞI TẠO GIÁ TRỊ MẶC ĐỊNH
    this.errorMessage,
    this.isSuccess = false,
  });

  // Tạo trạng thái ban đầu khi chỉnh sửa một item có sẵn
  factory AddItemState.fromClothingItem(ClothingItem item) {
    Set<String> stringToSet(String? s) => (s == null || s.isEmpty) ? {} : s.split(', ').toSet();

    return AddItemState(
      id: item.id,
      name: item.name,
      imagePath: item.imagePath,
      selectedClosetId: item.closetId,
      selectedCategoryValue: item.category,
      selectedColors: stringToSet(item.color),
      selectedSeasons: stringToSet(item.season),
      selectedOccasions: stringToSet(item.occasion),
      selectedMaterials: stringToSet(item.material),
      selectedPatterns: stringToSet(item.pattern),
      isEditing: true,
    );
  }

  // Hàm copyWith quen thuộc
  AddItemState copyWith({
    String? id,
    String? name,
    File? image,
    String? imagePath,
    String? selectedClosetId,
    String? selectedCategoryValue,
    Set<String>? selectedColors,
    Set<String>? selectedSeasons,
    Set<String>? selectedOccasions,
    Set<String>? selectedMaterials,
    Set<String>? selectedPatterns,
    bool? isLoading,
    bool? isEditing,
    bool? isAnalyzing, // <<< THÊM VÀO HÀM COPYWITH
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AddItemState(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      imagePath: imagePath ?? this.imagePath,
      selectedClosetId: selectedClosetId ?? this.selectedClosetId,
      selectedCategoryValue: selectedCategoryValue ?? this.selectedCategoryValue,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedSeasons: selectedSeasons ?? this.selectedSeasons,
      selectedOccasions: selectedOccasions ?? this.selectedOccasions,
      selectedMaterials: selectedMaterials ?? this.selectedMaterials,
      selectedPatterns: selectedPatterns ?? this.selectedPatterns,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing, // <<< THÊM VÀO ĐÂY
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}