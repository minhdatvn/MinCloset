// lib/states/closet_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

@immutable
class ClosetDetailState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String searchQuery;
  final List<ClothingItem> items;
  final String? errorMessage;
  final bool isMultiSelectMode;
  final Set<String> selectedItemIds;
  
  // <<< THÊM CÁC THUỘC TÍNH CÒN THIẾU Ở ĐÂY >>>
  final int page;
  final bool isSearching;

  const ClosetDetailState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.searchQuery = '',
    this.items = const [],
    this.errorMessage,
    this.isMultiSelectMode = false,
    this.selectedItemIds = const {},
    this.page = 0, // Giá trị mặc định
    this.isSearching = false, // Giá trị mặc định
  });

  ClosetDetailState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? searchQuery,
    List<ClothingItem>? items,
    String? errorMessage,
    bool? isMultiSelectMode,
    Set<String>? selectedItemIds,
    bool clearError = false,
    int? page,
    bool? isSearching,
  }) {
    return ClosetDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      page: page ?? this.page,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        hasMore,
        searchQuery,
        items,
        errorMessage,
        isMultiSelectMode,
        selectedItemIds,
        page,
        isSearching,
      ];
}