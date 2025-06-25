// lib/states/item_filter_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';

@immutable
class ItemFilterState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore; 
  final bool hasMore;       
  final String searchQuery;
  final List<ClothingItem> items;
  final OutfitFilter activeFilters;
  final String? errorMessage;
  final bool isMultiSelectMode;
  final Set<String> selectedItemIds;

  const ItemFilterState({
    this.isLoading = true,
    this.isLoadingMore = false, 
    this.hasMore = true,        
    this.searchQuery = '',
    this.items = const [],      
    this.activeFilters = const OutfitFilter(),
    this.errorMessage,
    this.isMultiSelectMode = false,
    this.selectedItemIds = const {},
  });

  ItemFilterState copyWith({
    bool? isLoading,
    bool? isLoadingMore, 
    bool? hasMore,       
    String? searchQuery,
    List<ClothingItem>? items, 
    OutfitFilter? activeFilters,
    String? errorMessage,
    bool? isMultiSelectMode,     
    Set<String>? selectedItemIds,
    bool clearError = false,
  }) {
    return ItemFilterState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore, 
      hasMore: hasMore ?? this.hasMore,                   
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,                         
      activeFilters: activeFilters ?? this.activeFilters,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode, 
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadingMore, hasMore, searchQuery, 
                              items, activeFilters, errorMessage, isMultiSelectMode, selectedItemIds,];
        
}