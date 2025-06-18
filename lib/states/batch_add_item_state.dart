// lib/states/batch_add_item_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/states/add_item_state.dart';

@immutable
class BatchAddItemState extends Equatable {
  final List<XFile> images;
  final List<AddItemState> itemStates;
  final int currentIndex;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const BatchAddItemState({
    this.images = const [],
    this.itemStates = const [],
    this.currentIndex = 0,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  BatchAddItemState copyWith({
    List<XFile>? images,
    List<AddItemState>? itemStates,
    int? currentIndex,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BatchAddItemState(
      images: images ?? this.images,
      itemStates: itemStates ?? this.itemStates,
      currentIndex: currentIndex ?? this.currentIndex,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        images,
        itemStates,
        currentIndex,
        isSaving,
        saveSuccess,
        errorMessage,
      ];
}