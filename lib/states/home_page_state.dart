// lib/states/home_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';

@immutable
class HomePageState extends Equatable {
  final bool isLoading;
  // THAY THẾ suggestion (String) BẰNG suggestionResult (SuggestionResult)
  final SuggestionResult? suggestionResult;
  final Map<String, dynamic>? weather;
  final String? errorMessage;
  final DateTime? suggestionTimestamp;
  final int suggestionId;

  const HomePageState({
    this.isLoading = false,
    this.suggestionResult, // <<< THAY ĐỔI
    this.weather,
    this.errorMessage,
    this.suggestionTimestamp,
    this.suggestionId = 0,
  });

  HomePageState copyWith({
    bool? isLoading,
    SuggestionResult? suggestionResult, // <<< THAY ĐỔI
    Map<String, dynamic>? weather,
    String? errorMessage,
    DateTime? suggestionTimestamp,
    int? suggestionId,
    bool clearError = false,
  }) {
    return HomePageState(
      isLoading: isLoading ?? this.isLoading,
      suggestionResult: suggestionResult ?? this.suggestionResult, // <<< THAY ĐỔI
      weather: weather ?? this.weather,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      suggestionTimestamp: suggestionTimestamp ?? this.suggestionTimestamp,
      suggestionId: suggestionId ?? this.suggestionId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        suggestionResult, // <<< THAY ĐỔI
        weather,
        errorMessage,
        suggestionTimestamp,
        suggestionId,
      ];
}