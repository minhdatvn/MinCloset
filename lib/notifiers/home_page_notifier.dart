// lib/notifiers/home_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/services/weather_image_service.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final GetOutfitSuggestionUseCase _getSuggestionUseCase;
  final NotificationService _notificationService;
  final WeatherImageService _weatherImageService;

  HomePageNotifier(this._getSuggestionUseCase, this._notificationService, this._weatherImageService)
      : super(const HomePageState()) {
    init();
  }

  Future<void> init() async {
    await refreshWeatherOnly();
  }

  Future<void> refreshWeatherOnly() async {
    logger.i("Weather refresh triggered.");
    final weatherEither = await _getSuggestionUseCase.getWeatherForSuggestion();

    if (mounted) {
      weatherEither.fold(
        (failure) {
          logger.e("Failed to refresh weather: ${failure.message}");
        },
        (weatherData) {
          // Lấy đường dẫn ảnh ngay khi có dữ liệu thời tiết
          final newPath = _weatherImageService.getBackgroundImageForWeather(
              weatherData['weather'][0]['icon'] as String?);

          // Cập nhật cả thời tiết và đường dẫn ảnh cùng lúc
          state = state.copyWith(weather: weatherData, backgroundImagePath: newPath);
        },
      );
    }
  }

  void refreshBackgroundImage() {
    if (state.isRefreshingBackground) return;

    // Lấy đường dẫn ảnh mới, truyền vào ảnh hiện tại để loại trừ
    final newPath = _weatherImageService.getBackgroundImageForWeather(
        state.weather?['weather'][0]['icon'] as String?,
        currentPath: state.backgroundImagePath, // Truyền ảnh hiện tại
    );
        
    // Cập nhật state với đường dẫn mới và bật cờ loading
    state = state.copyWith(
      isRefreshingBackground: true,
      backgroundImagePath: newPath,
    );

    // Sau 1 giây, tắt cờ loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        state = state.copyWith(isRefreshingBackground: false);
      }
    });
  }

  Future<void> getNewSuggestion({String? purpose}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final resultEither = await _getSuggestionUseCase.execute(purpose: purpose);

    if (!mounted) return;

    resultEither.fold(
      (failure) {
        logger.e('Failed to get new suggestions', error: failure.message);
        _notificationService.showBanner(message: failure.message);
        state = state.copyWith(isLoading: false);
      },
      (result) {
        final weatherData = result['weather'] as Map<String, dynamic>?;
        // Lấy đường dẫn ảnh mới dựa trên dữ liệu thời tiết mới
        final newPath = _weatherImageService.getBackgroundImageForWeather(
            weatherData?['weather'][0]['icon'] as String?);

        state = state.copyWith(
          isLoading: false,
          suggestionResult: result['suggestionResult'] as SuggestionResult?,
          weather: weatherData,
          suggestionTimestamp: DateTime.now(),
          suggestionId: state.suggestionId + 1,
          backgroundImagePath: newPath, // Cập nhật đường dẫn ảnh
        );
      },
    );
  }
}

final homeProvider =
    StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  final getSuggestionUseCase = ref.watch(getOutfitSuggestionUseCaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final weatherImageService = ref.watch(weatherImageServiceProvider).value!;

  return HomePageNotifier(getSuggestionUseCase, notificationService, weatherImageService);
});