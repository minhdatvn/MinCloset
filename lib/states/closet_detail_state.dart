// lib/states/closet_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/models/clothing_item.dart';

@immutable
class ClosetDetailState extends Equatable {
  final bool isLoading;
  final String searchQuery;
  final List<ClothingItem> items;
  final String? errorMessage;

  const ClosetDetailState({
    this.isLoading = true,
    this.searchQuery = '',
    this.items = const [],
    this.errorMessage,
  });

  ClosetDetailState copyWith({
    bool? isLoading,
    String? searchQuery,
    List<ClothingItem>? items,
    String? errorMessage,
  }) {
    return ClosetDetailState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, searchQuery, items, errorMessage];
}