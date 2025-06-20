// lib/states/batch_add_item_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/notifiers/add_item_notifier.dart';

@immutable
class BatchAddItemState extends Equatable {
  final bool isLoading;
  final bool analysisSuccess;
  final List<ItemNotifierArgs> itemArgsList;
  final int currentIndex;
  final bool isSaving;
  final bool saveSuccess;
  
  // <<< THAY ĐỔI: Tách thành 2 trạng thái lỗi riêng biệt >>>
  final String? analysisErrorMessage;
  final String? saveErrorMessage;

  const BatchAddItemState({
    this.isLoading = false,
    this.analysisSuccess = false,
    this.itemArgsList = const [],
    this.currentIndex = 0,
    this.isSaving = false,
    this.saveSuccess = false,
    this.analysisErrorMessage,
    this.saveErrorMessage,
  });

  BatchAddItemState copyWith({
    bool? isLoading,
    bool? analysisSuccess,
    List<ItemNotifierArgs>? itemArgsList,
    int? currentIndex,
    bool? isSaving,
    bool? saveSuccess,
    String? analysisErrorMessage,
    String? saveErrorMessage,
    bool clearAnalysisError = false,
    bool clearSaveError = false,
  }) {
    return BatchAddItemState(
      isLoading: isLoading ?? this.isLoading,
      analysisSuccess: analysisSuccess ?? this.analysisSuccess,
      itemArgsList: itemArgsList ?? this.itemArgsList,
      currentIndex: currentIndex ?? this.currentIndex,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      analysisErrorMessage: clearAnalysisError ? null : analysisErrorMessage ?? this.analysisErrorMessage,
      saveErrorMessage: clearSaveError ? null : saveErrorMessage ?? this.saveErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        analysisSuccess,
        itemArgsList,
        currentIndex,
        isSaving,
        saveSuccess,
        analysisErrorMessage,
        saveErrorMessage,
      ];
}