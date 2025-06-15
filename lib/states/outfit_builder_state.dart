// lib/states/outfit_builder_state.dart
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

// Dùng Equatable để dễ dàng so sánh các đối tượng state
// Đừng quên thêm `equatable: ^2.0.5` vào pubspec.yaml
import 'package:equatable/equatable.dart';

@immutable
class OutfitBuilderState extends Equatable {
  // Trạng thái dữ liệu
  final List<ClothingItem> availableItems;
  final Map<String, ClothingItem> itemsOnCanvas;
  final String? selectedStickerId;

  // Trạng thái UI
  final bool isLoading; // Tải danh sách đồ ban đầu
  final bool isSaving;   // Trạng thái đang lưu bộ đồ
  final String? errorMessage;
  final bool saveSuccess;

  const OutfitBuilderState({
    this.availableItems = const [],
    this.itemsOnCanvas = const {},
    this.selectedStickerId,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  OutfitBuilderState copyWith({
    List<ClothingItem>? availableItems,
    Map<String, ClothingItem>? itemsOnCanvas,
    String? selectedStickerId,
    bool? clearSelectedSticker, // Thêm cờ để xóa lựa chọn
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return OutfitBuilderState(
      availableItems: availableItems ?? this.availableItems,
      itemsOnCanvas: itemsOnCanvas ?? this.itemsOnCanvas,
      selectedStickerId: clearSelectedSticker == true ? null : selectedStickerId ?? this.selectedStickerId,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  // Bắt buộc phải có khi dùng Equatable
  @override
  List<Object?> get props => [
        availableItems,
        itemsOnCanvas,
        selectedStickerId,
        isLoading,
        isSaving,
        errorMessage,
        saveSuccess
      ];
}