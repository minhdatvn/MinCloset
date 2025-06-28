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
  final String? thumbnailPath;
  final String? selectedClosetId;
  final String selectedCategoryValue;
  final Set<String> selectedColors;
  final Set<String> selectedSeasons;
  final Set<String> selectedOccasions;
  final Set<String> selectedMaterials;
  final Set<String> selectedPatterns;
  final bool isFavorite; // <<< THÊM DÒNG NÀY

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
    this.thumbnailPath,
    this.selectedClosetId,
    this.selectedCategoryValue = '',
    this.selectedColors = const {},
    this.selectedSeasons = const {},
    this.selectedOccasions = const {},
    this.selectedMaterials = const {},
    this.selectedPatterns = const {},
    this.isFavorite = false, // <<< THÊM GIÁ TRỊ MẶC ĐỊNH
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
      thumbnailPath: item.thumbnailPath,
      selectedClosetId: item.closetId,
      selectedCategoryValue: item.category,
      selectedColors: stringToSet(item.color),
      selectedSeasons: stringToSet(item.season),
      selectedOccasions: stringToSet(item.occasion),
      selectedMaterials: stringToSet(item.material),
      selectedPatterns: stringToSet(item.pattern),
      isFavorite: item.isFavorite, // <<< THÊM DÒNG NÀY
      isEditing: true,
    );
  }

  AddItemState copyWith({
    String? id,
    String? name,
    File? image,
    String? imagePath,
    String? thumbnailPath,
    String? selectedClosetId,
    String? selectedCategoryValue,
    Set<String>? selectedColors,
    Set<String>? selectedSeasons,
    Set<String>? selectedOccasions,
    Set<String>? selectedMaterials,
    Set<String>? selectedPatterns,
    bool? isFavorite, // <<< THÊM DÒNG NÀY
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
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      selectedClosetId: selectedClosetId ?? this.selectedClosetId,
      selectedCategoryValue: selectedCategoryValue ?? this.selectedCategoryValue,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedSeasons: selectedSeasons ?? this.selectedSeasons,
      selectedOccasions: selectedOccasions ?? this.selectedOccasions,
      selectedMaterials: selectedMaterials ?? this.selectedMaterials,
      selectedPatterns: selectedPatterns ?? this.selectedPatterns,
      isFavorite: isFavorite ?? this.isFavorite, // <<< THÊM DÒNG NÀY
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        id, name, image, imagePath, thumbnailPath, selectedClosetId,
        selectedCategoryValue, selectedColors, selectedSeasons,
        selectedOccasions, selectedMaterials, selectedPatterns,
        isFavorite, // <<< THÊM isFavorite VÀO ĐÂY
        isLoading, isEditing, isAnalyzing, errorMessage, isSuccess,
      ];
}