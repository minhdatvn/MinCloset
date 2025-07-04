// lib/notifiers/closet_insights_notifier.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/closet_insights.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/get_closet_insights_use_case.dart';

// --- LỚP STATE ---
class ClosetInsightsState extends Equatable {
  final bool isLoading;
  final ClosetInsights? insights;
  final String? errorMessage;

  const ClosetInsightsState({
    this.isLoading = true,
    this.insights,
    this.errorMessage,
  });

  ClosetInsightsState copyWith({
    bool? isLoading,
    ClosetInsights? insights,
    String? errorMessage,
  }) {
    return ClosetInsightsState(
      isLoading: isLoading ?? this.isLoading,
      insights: insights ?? this.insights,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, insights, errorMessage];
}

// --- LỚP NOTIFIER ---
class ClosetInsightsNotifier extends StateNotifier<ClosetInsightsState> {
  final GetClosetInsightsUseCase _getInsightsUseCase;

  ClosetInsightsNotifier(this._getInsightsUseCase) : super(const ClosetInsightsState()) {
    fetchInsights();
  }

  Future<void> fetchInsights() async {
    state = const ClosetInsightsState(isLoading: true);
    final result = await _getInsightsUseCase.execute();

    if (mounted) {
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
        (insights) => state = state.copyWith(isLoading: false, insights: insights),
      );
    }
  }
}

// --- PROVIDER ---
final closetInsightsProvider = StateNotifierProvider.autoDispose<ClosetInsightsNotifier, ClosetInsightsState>((ref) {
  final useCase = ref.watch(getClosetInsightsUseCaseProvider);
  return ClosetInsightsNotifier(useCase);
});