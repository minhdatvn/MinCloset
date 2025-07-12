// lib/states/batch_add_item_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';

enum AnalysisStage { preparing, analyzing } // <<< Enum để định nghĩa các giai đoạn loading >>>

@immutable
class BatchItemDetailState extends Equatable {
  final bool isLoading;
  final bool analysisSuccess;
  final List<ItemDetailNotifierArgs> itemArgsList;
  final int currentIndex;
  final bool isSaving;
  final bool saveSuccess;
  
  // <<< Tách thành 2 trạng thái lỗi riêng biệt >>>
  final String? analysisErrorMessage;
  final String? saveErrorMessage;

  // <<< Các thuộc tính để theo dõi tiến độ >>>
  final AnalysisStage stage;
  final int totalItemsToProcess;
  final int itemsProcessed;

  const BatchItemDetailState({
    this.isLoading = false,
    this.analysisSuccess = false,
    this.itemArgsList = const [],
    this.currentIndex = 0,
    this.isSaving = false,
    this.saveSuccess = false,
    this.analysisErrorMessage,
    this.saveErrorMessage,
    this.stage = AnalysisStage.preparing,
    this.totalItemsToProcess = 0,
    this.itemsProcessed = 0,
  });

  BatchItemDetailState copyWith({
    bool? isLoading,
    bool? analysisSuccess,
    List<ItemDetailNotifierArgs>? itemArgsList,
    int? currentIndex,
    bool? isSaving,
    bool? saveSuccess,
    String? analysisErrorMessage,
    String? saveErrorMessage,
    AnalysisStage? stage,
    int? totalItemsToProcess,
    int? itemsProcessed,
    bool clearAnalysisError = false,
    bool clearSaveError = false,
  }) {
    return BatchItemDetailState(
      isLoading: isLoading ?? this.isLoading,
      analysisSuccess: analysisSuccess ?? this.analysisSuccess,
      itemArgsList: itemArgsList ?? this.itemArgsList,
      currentIndex: currentIndex ?? this.currentIndex,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      analysisErrorMessage: clearAnalysisError ? null : analysisErrorMessage ?? this.analysisErrorMessage,
      saveErrorMessage: clearSaveError ? null : saveErrorMessage ?? this.saveErrorMessage,
      stage: stage ?? this.stage,
      totalItemsToProcess: totalItemsToProcess ?? this.totalItemsToProcess,
      itemsProcessed: itemsProcessed ?? this.itemsProcessed,
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
        stage,
        totalItemsToProcess,
        itemsProcessed,
      ];
}