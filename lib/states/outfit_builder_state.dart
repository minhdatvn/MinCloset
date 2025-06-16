// lib/states/outfit_builder_state.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart'; // <<< THÊM IMPORT NÀY

@immutable
class OutfitBuilderState extends Equatable {
  // Trạng thái dữ liệu
  final List<ClothingItem> allItems;
  final List<ClothingItem> filteredItems;
  // <<< THAY THẾ `activeCategoryFilter` BẰNG ĐỐI TƯỢNG `OutfitFilter`
  final OutfitFilter activeFilters;
  
  final Map<String, ClothingItem> itemsOnCanvas;
  final String? selectedStickerId;

  // Trạng thái UI
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool saveSuccess;

  const OutfitBuilderState({
    this.allItems = const [],
    this.filteredItems = const [],
    this.activeFilters = const OutfitFilter(), // <<< THAY ĐỔI: Khởi tạo bộ lọc rỗng
    this.itemsOnCanvas = const {},
    this.selectedStickerId,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  // <<< CẬP NHẬT HÀM `copyWith` ĐỂ CÓ THAM SỐ `activeFilters`
  OutfitBuilderState copyWith({
    List<ClothingItem>? allItems,
    List<ClothingItem>? filteredItems,
    OutfitFilter? activeFilters,
    Map<String, ClothingItem>? itemsOnCanvas,
    String? selectedStickerId,
    bool? clearSelectedSticker,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return OutfitBuilderState(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      activeFilters: activeFilters ?? this.activeFilters, // Thêm tham số này vào
      itemsOnCanvas: itemsOnCanvas ?? this.itemsOnCanvas,
      selectedStickerId: clearSelectedSticker == true ? null : selectedStickerId ?? this.selectedStickerId,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
  
  // <<< CẬP NHẬT `props` CHO EQUATABLE
  @override
  List<Object?> get props => [
        allItems,
        filteredItems,
        activeFilters,
        itemsOnCanvas,
        selectedStickerId,
        isLoading,
        isSaving,
        errorMessage,
        saveSuccess
      ];
}