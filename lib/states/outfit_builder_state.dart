// lib/states/outfit_builder_state.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

@immutable
class OutfitBuilderState extends Equatable {
  // Trạng thái cho biết đang tải danh sách vật phẩm hay không
  final bool isLoading;
  // <<< THÊM MỚI: Trạng thái cho biết có đang lưu bộ đồ hay không >>>
  final bool isSaving;
  // Danh sách tất cả vật phẩm để hiển thị trong ngăn sticker
  final List<ClothingItem> allItems;
  // Trạng thái lỗi nếu có
  final String? errorMessage;
  // Trạng thái khi lưu thành công
  final bool saveSuccess;

  const OutfitBuilderState({
    this.isLoading = true,
    this.isSaving = false, // <<< THÊM MỚI
    this.allItems = const [],
    this.errorMessage,
    this.saveSuccess = false,
  });

  OutfitBuilderState copyWith({
    bool? isLoading,
    bool? isSaving, // <<< THÊM MỚI
    List<ClothingItem>? allItems,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return OutfitBuilderState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving, // <<< THÊM MỚI
      allItems: allItems ?? this.allItems,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving, // <<< THÊM MỚI
        allItems,
        errorMessage,
        saveSuccess
      ];
}