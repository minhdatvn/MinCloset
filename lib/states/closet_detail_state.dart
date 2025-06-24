// lib/states/closet_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

@immutable
class ClosetDetailState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore; // <<< THÊM MỚI
  final bool hasMore;       // <<< THÊM MỚI
  final String searchQuery;
  final List<ClothingItem> items;
  final String? errorMessage;

  const ClosetDetailState({
    this.isLoading = true,
    this.isLoadingMore = false, // <<< THÊM MỚI
    this.hasMore = true,        // <<< THÊM MỚI
    this.searchQuery = '',
    this.items = const [],
    this.errorMessage,
  });

  ClosetDetailState copyWith({
    bool? isLoading,
    bool? isLoadingMore, // <<< THÊM MỚI
    bool? hasMore,       // <<< THÊM MỚI
    String? searchQuery,
    List<ClothingItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClosetDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore, // <<< THÊM MỚI
      hasMore: hasMore ?? this.hasMore,                   // <<< THÊM MỚI
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadingMore, hasMore, searchQuery, items, errorMessage];
}