// lib/notifiers/home_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  // <<< THAY ĐỔI 1: Khai báo các dependency tường minh >>>
  final GetOutfitSuggestionUseCase _getSuggestionUseCase;
  final NotificationService _notificationService;

  // <<< THAY ĐỔI 2: Truyền dependency vào constructor và bỏ `_ref` >>>
  HomePageNotifier(this._getSuggestionUseCase, this._notificationService)
      : super(const HomePageState()) {
    init();
  }

  Future<void> init() async {
    await refreshWeatherOnly();
  }

  Future<void> refreshWeatherOnly() async {
    logger.i("Weather refresh triggered.");
    // <<< THAY ĐỔI 3: Sử dụng UseCase đã được inject >>>
    final weatherEither = await _getSuggestionUseCase.getWeatherForSuggestion();

    if (mounted) {
      weatherEither.fold(
        (failure) {
          logger.e("Failed to refresh weather: ${failure.message}");
        },
        (weatherData) => state = state.copyWith(weather: weatherData),
      );
    }
  }

  void refreshBackgroundImage() {
    // Chỉ cần tăng giá trị của trigger để kích hoạt việc build lại UI
    state = state.copyWith(backgroundImageTrigger: state.backgroundImageTrigger + 1);
  }

  Future<void> getNewSuggestion({String? purpose}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    // <<< THAY ĐỔI 4: Sử dụng UseCase đã được inject >>>
    final resultEither = await _getSuggestionUseCase.execute(purpose: purpose);

    if (!mounted) return;

    resultEither.fold(
      (failure) {
        logger.e('Failed to get new suggestions', error: failure.message);
        // <<< THAY ĐỔI 5: Sử dụng NotificationService đã được inject >>>
        _notificationService.showBanner(message: failure.message);
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

final homeProvider =
    StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  // <<< THAY ĐỔI 6: Lấy dependency và truyền vào Notifier >>>
  final getSuggestionUseCase = ref.watch(getOutfitSuggestionUseCaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return HomePageNotifier(getSuggestionUseCase, notificationService);
});