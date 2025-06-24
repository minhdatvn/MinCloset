// lib/states/add_item_state.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

@immutable
class AddItemState extends Equatable {
  // Trạng thái của các trường trong form
  final String id;
  final String name;
  final File? image;
  final String? imagePath;
  final String? thumbnailPath; // <<< THÊM MỚI
  final String? selectedClosetId;
  final String selectedCategoryValue;
  final Set<String> selectedColors;
  final Set<String> selectedSeasons;
  final Set<String> selectedOccasions;
  final Set<String> selectedMaterials;
  final Set<String> selectedPatterns;

  // Trạng thái của UI
  final bool isLoading;
  final bool isEditing;
  final bool isAnalyzing;
  final String? errorMessage;
  final bool isSuccess;

  const AddItemState({
    this.id = '',
    this.name = '',
    this.image,
    this.imagePath,
    this.thumbnailPath, // <<< THÊM MỚI
    this.selectedClosetId,
    this.selectedCategoryValue = '',
    this.selectedColors = const {},
    this.selectedSeasons = const {},
    this.selectedOccasions = const {},
    this.selectedMaterials = const {},
    this.selectedPatterns = const {},
    this.isLoading = false,
    this.isEditing = false,
    this.isAnalyzing = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  factory AddItemState.fromClothingItem(ClothingItem item) {
    Set<String> stringToSet(String? s) => (s == null || s.isEmpty) ? {} : s.split(', ').toSet();

    return AddItemState(
      id: item.id,
      name: item.name,
      imagePath: item.imagePath,
      thumbnailPath: item.thumbnailPath, // <<< THÊM MỚI
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

  AddItemState copyWith({
    String? id,
    String? name,
    File? image,
    String? imagePath,
    String? thumbnailPath, // <<< THÊM MỚI
    String? selectedClosetId,
    String? selectedCategoryValue,
    Set<String>? selectedColors,
    Set<String>? selectedSeasons,
    Set<String>? selectedOccasions,
    Set<String>? selectedMaterials,
    Set<String>? selectedPatterns,
    bool? isLoading,
    bool? isEditing,
    bool? isAnalyzing,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AddItemState(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath, // <<< THÊM MỚI
      selectedClosetId: selectedClosetId ?? this.selectedClosetId,
      selectedCategoryValue: selectedCategoryValue ?? this.selectedCategoryValue,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedSeasons: selectedSeasons ?? this.selectedSeasons,
      selectedOccasions: selectedOccasions ?? this.selectedOccasions,
      selectedMaterials: selectedMaterials ?? this.selectedMaterials,
      selectedPatterns: selectedPatterns ?? this.selectedPatterns,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        imagePath,
        thumbnailPath, // <<< THÊM MỚI
        selectedClosetId,
        selectedCategoryValue,
        selectedColors,
        selectedSeasons,
        selectedOccasions,
        selectedMaterials,
        selectedPatterns,
        isLoading,
        isEditing,
        isAnalyzing,
        errorMessage,
        isSuccess,
      ];
}