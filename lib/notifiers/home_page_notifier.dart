// lib/notifiers/home_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  HomePageNotifier(this._ref) : super(const HomePageState()) {
    init();
  }

  Future<void> init() async {
    await refreshWeatherOnly();
  }

  Future<void> refreshWeatherOnly() async {
    logger.i("Weather refresh triggered.");
    final getSuggestionUseCase = _ref.read(getOutfitSuggestionUseCaseProvider);
    final weatherEither = await getSuggestionUseCase.getWeatherForSuggestion();

    if (mounted) {
      weatherEither.fold(
        (failure) {
          logger.e("Failed to refresh weather: ${failure.message}");
          // Tùy chọn: hiển thị lỗi thời tiết cho người dùng
          // state = state.copyWith(errorMessage: failure.message);
        },
        (weatherData) => state = state.copyWith(weather: weatherData),
      );
    }
  }

  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final getSuggestion = _ref.read(getOutfitSuggestionUseCaseProvider);
    final resultEither = await getSuggestion.execute();

    if (!mounted) return;

    resultEither.fold(
      (failure) {
        logger.e('Failed to get new suggestions', error: failure.message);
        _ref.read(notificationServiceProvider).showBanner(message: failure.message);
        state = state.copyWith(isLoading: false);
      },
      (result) {
        state = state.copyWith(
          isLoading: false,
          suggestionResult: result['suggestionResult'] as SuggestionResult?,
          weather: result['weather'] as Map<String, dynamic>?,
          suggestionTimestamp: DateTime.now(),
          suggestionId: state.suggestionId + 1,
        );
      },
    );
  }
}

final homeProvider = StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});