// lib/states/home_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class HomePageState extends Equatable {
  final bool isLoading;
  final String? suggestion;
  final Map<String, dynamic>? weather;
  final String? errorMessage;
  final DateTime? suggestionTimestamp;
  final int suggestionId;

  const HomePageState({
    this.isLoading = false, // <<< THAY ĐỔI: Mặc định không loading
    this.suggestion,
    this.weather,
    this.errorMessage,
    this.suggestionTimestamp,
    this.suggestionId = 0,
  });

  HomePageState copyWith({
    bool? isLoading,
    String? suggestion,
    Map<String, dynamic>? weather,
    String? errorMessage,
    DateTime? suggestionTimestamp,
    int? suggestionId,
    bool clearError = false,
  }) {
    return HomePageState(
      isLoading: isLoading ?? this.isLoading,
      suggestion: suggestion ?? this.suggestion,
      weather: weather ?? this.weather,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      suggestionTimestamp: suggestionTimestamp ?? this.suggestionTimestamp,
      suggestionId: suggestionId ?? this.suggestionId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        suggestion,
        weather,
        errorMessage,
        suggestionTimestamp,
        suggestionId,
      ];
}