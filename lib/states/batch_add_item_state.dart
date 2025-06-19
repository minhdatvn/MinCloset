// lib/states/batch_add_item_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/states/add_item_state.dart';

@immutable
class BatchAddItemState extends Equatable {
  final bool isLoading; // Cờ cho màn hình chờ
  final bool analysisSuccess; // Cờ báo hiệu phân tích xong
  final List<AddItemState> itemStates;
  final int currentIndex;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const BatchAddItemState({
    this.isLoading = false,
    this.analysisSuccess = false,
    this.itemStates = const [],
    this.currentIndex = 0,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  BatchAddItemState copyWith({
    bool? isLoading,
    bool? analysisSuccess,
    List<XFile>? images, // Xóa bỏ images vì không còn lưu trực tiếp
    List<AddItemState>? itemStates,
    int? currentIndex,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BatchAddItemState(
      isLoading: isLoading ?? this.isLoading,
      analysisSuccess: analysisSuccess ?? this.analysisSuccess,
      itemStates: itemStates ?? this.itemStates,
      currentIndex: currentIndex ?? this.currentIndex,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        analysisSuccess,
        itemStates,
        currentIndex,
        isSaving,
        saveSuccess,
        errorMessage,
      ];
}