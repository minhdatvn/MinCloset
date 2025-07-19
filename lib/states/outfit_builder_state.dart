// lib/states/outfit_builder_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

@immutable
class OutfitBuilderState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final List<ClothingItem> allItems;
  final String? errorMessage;
  final bool saveSuccess;

  const OutfitBuilderState({
    this.isLoading = true,
    this.isSaving = false,
    this.allItems = const [],
    this.errorMessage,
    this.saveSuccess = false,
  });

  OutfitBuilderState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<ClothingItem>? allItems,
    String? errorMessage,
    bool? saveSuccess,
  }) {
    return OutfitBuilderState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      allItems: allItems ?? this.allItems,
      errorMessage: errorMessage ?? this.errorMessage,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        allItems,
        errorMessage,
        saveSuccess,
      ];
}