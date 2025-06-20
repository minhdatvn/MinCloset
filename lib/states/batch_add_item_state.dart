// lib/states/batch_add_item_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart'; // <<< THÊM IMPORT

@immutable
class BatchAddItemState extends Equatable {
  final bool isLoading;
  final bool analysisSuccess;

  // <<< THAY ĐỔI: Lưu toàn bộ đối tượng Args để đảm bảo dữ liệu được truyền đi
  final List<ItemNotifierArgs> itemArgsList;

  final int currentIndex;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const BatchAddItemState({
    this.isLoading = false,
    this.analysisSuccess = false,
    this.itemArgsList = const [], // <<< THAY ĐỔI
    this.currentIndex = 0,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  BatchAddItemState copyWith({
    bool? isLoading,
    bool? analysisSuccess,
    List<ItemNotifierArgs>? itemArgsList, // <<< THAY ĐỔI
    int? currentIndex,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BatchAddItemState(
      isLoading: isLoading ?? this.isLoading,
      analysisSuccess: analysisSuccess ?? this.analysisSuccess,
      itemArgsList: itemArgsList ?? this.itemArgsList, // <<< THAY ĐỔI
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
        itemArgsList, // <<< THAY ĐỔI
        currentIndex,
        isSaving,
        saveSuccess,
        errorMessage,
      ];
}