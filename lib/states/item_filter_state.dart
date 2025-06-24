// lib/states/item_filter_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';

@immutable
class ItemFilterState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore; // <<< THÊM MỚI
  final bool hasMore;       // <<< THÊM MỚI
  final String searchQuery;
  final List<ClothingItem> items; // <<< THAY ĐỔI: allItems và filteredItems gộp thành một
  final OutfitFilter activeFilters;
  final String? errorMessage;

  const ItemFilterState({
    this.isLoading = true,
    this.isLoadingMore = false, // <<< THÊM MỚI
    this.hasMore = true,        // <<< THÊM MỚI
    this.searchQuery = '',
    this.items = const [],      // <<< THAY ĐỔI
    this.activeFilters = const OutfitFilter(),
    this.errorMessage,
  });

  ItemFilterState copyWith({
    bool? isLoading,
    bool? isLoadingMore, // <<< THÊM MỚI
    bool? hasMore,       // <<< THÊM MỚI
    String? searchQuery,
    List<ClothingItem>? items, // <<< THAY ĐỔI
    OutfitFilter? activeFilters,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ItemFilterState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore, // <<< THÊM MỚI
      hasMore: hasMore ?? this.hasMore,                   // <<< THÊM MỚI
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,                         // <<< THAY ĐỔI
      activeFilters: activeFilters ?? this.activeFilters,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadingMore, hasMore, searchQuery, items, activeFilters, errorMessage];
}