// lib/states/item_filter_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';

@immutable
class ItemFilterState extends Equatable {
  final bool isLoading;
  final String searchQuery;
  final List<ClothingItem> allItems; // Danh sách gốc chứa tất cả item
  final List<ClothingItem> filteredItems; // Danh sách đã được lọc để hiển thị
  final OutfitFilter activeFilters; // Đối tượng chứa các điều kiện lọc
  final String? errorMessage;

  const ItemFilterState({
    this.isLoading = true,
    this.searchQuery = '',
    this.allItems = const [],
    this.filteredItems = const [],
    this.activeFilters = const OutfitFilter(),
    this.errorMessage,
  });

  ItemFilterState copyWith({
    bool? isLoading,
    String? searchQuery,
    List<ClothingItem>? allItems,
    List<ClothingItem>? filteredItems,
    OutfitFilter? activeFilters,
    String? errorMessage,
  }) {
    return ItemFilterState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      activeFilters: activeFilters ?? this.activeFilters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, searchQuery, allItems, filteredItems, activeFilters, errorMessage];
}