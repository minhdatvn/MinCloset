// lib/states/log_wear_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// Enum để xác định loại nội dung cần chọn
enum SelectionType { items, outfits }

@immutable
class LogWearState<T> extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  
  final List<T> allData; // Danh sách tất cả item/outfit
  final Set<String> selectedIds; // Set các ID đã được chọn

  // NOTE: Phần tìm kiếm và lọc sẽ được thêm vào sau nếu cần
  // final String searchQuery;
  // final OutfitFilter activeFilters;

  const LogWearState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.allData = const [],
    this.selectedIds = const {},
  });

  LogWearState<T> copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    List<T>? allData,
    Set<String>? selectedIds,
    bool clearError = false,
  }) {
    return LogWearState<T>(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      allData: allData ?? this.allData,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        hasMore,
        errorMessage,
        allData,
        selectedIds,
      ];
}