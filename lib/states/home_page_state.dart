// lib/states/home_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';

@immutable
class HomePageState extends Equatable {
  final bool isLoading;
  final SuggestionResult? suggestionResult;
  final Map<String, dynamic>? weather;
  final String? errorMessage;
  final DateTime? suggestionTimestamp;
  final int suggestionId;
  final bool isRefreshingBackground;
  final String? backgroundImagePath;

  const HomePageState({
    this.isLoading = false,
    this.suggestionResult,
    this.weather,
    this.errorMessage,
    this.suggestionTimestamp,
    this.suggestionId = 0,
    this.isRefreshingBackground = false,
    this.backgroundImagePath,
  });

  HomePageState copyWith({
    bool? isLoading,
    SuggestionResult? suggestionResult,
    Map<String, dynamic>? weather,
    String? errorMessage,
    DateTime? suggestionTimestamp,
    int? suggestionId,
    bool? isRefreshingBackground,
    String? backgroundImagePath,
    bool clearError = false,
  }) {
    return HomePageState(
      isLoading: isLoading ?? this.isLoading,
      suggestionResult: suggestionResult ?? this.suggestionResult,
      weather: weather ?? this.weather,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      suggestionTimestamp: suggestionTimestamp ?? this.suggestionTimestamp,
      suggestionId: suggestionId ?? this.suggestionId,
      isRefreshingBackground: isRefreshingBackground ?? this.isRefreshingBackground,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        suggestionResult,
        weather,
        errorMessage,
        suggestionTimestamp,
        suggestionId,
        isRefreshingBackground,
        backgroundImagePath,
      ];
}