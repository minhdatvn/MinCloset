// lib/notifiers/home_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/states/profile_page_state.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final GetOutfitSuggestionUseCase _getSuggestionUseCase;
  final NotificationService _notificationService;
  final Ref _ref;

  HomePageNotifier(
      this._getSuggestionUseCase, this._notificationService, this._ref)
      : super(const HomePageState()) {
    init();
    _ref.listen<ProfilePageState>(profileProvider, (previous, next) {
      // Nếu chế độ thành phố hoặc tên thành phố thủ công thay đổi
      if (previous != null && (previous.cityMode != next.cityMode || previous.manualCity != next.manualCity)) {
        // Gọi trực tiếp hàm làm mới của chính notifier này
        refreshWeatherOnly();
      }
    });
  }

  Future<void> init() async {
    await refreshWeatherOnly();
  }

  Future<void> refreshWeatherOnly() async {
      logger.i("Weather refresh triggered.");
      final weatherImageService = await _ref.read(weatherImageServiceProvider.future);
      final weatherEither = await _getSuggestionUseCase.getWeatherForSuggestion();

      if (mounted) {
        weatherEither.fold(
          (failure) {
            logger.e("Failed to refresh weather: ${failure.message}");
          },
          (weatherData) {
            final newPath = weatherImageService.getBackgroundImageForWeather(
                weatherData['weather'][0]['icon'] as String?);
            state = state.copyWith(weather: weatherData, backgroundImagePath: newPath);
          },
        );
      }
  }

  Future<void> refreshBackgroundImage() async {
    if (state.isRefreshingBackground) return;

    // Lấy service khi cần dùng
    final weatherImageService = await _ref.read(weatherImageServiceProvider.future);
    final newPath = weatherImageService.getBackgroundImageForWeather(
      state.weather?['weather'][0]['icon'] as String?,
      currentPath: state.backgroundImagePath,
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
    final weatherImageService = await _ref.read(weatherImageServiceProvider.future);

    // Bắt đầu logic xử lý lỗi và thử lại ở đây
    final resultEither = await _getSuggestionUseCase.execute(
      purpose: purpose,
      isWeatherReliable: true,
    );
    
    if (!mounted) return;

    resultEither.fold(
      (failure) {
        logger.e('Failed to get new suggestions', error: failure.message);
        _notificationService.showBanner(message: failure.message);
        state = state.copyWith(isLoading: false);
      },
      (result) async { //Chuyển thành hàm async
        //Bắt lấy kết quả và phát tín hiệu
        final completedQuests = await _ref.read(questRepositoryProvider).updateQuestProgress(QuestEvent.suggestionReceived);
        if (completedQuests.isNotEmpty && mounted) {
            _ref.read(completedQuestProvider.notifier).state = completedQuests.first;
        }

        final weatherData = result['weather'] as Map<String, dynamic>?;
        
        // Bây giờ 'weatherImageService' đã được định nghĩa và có thể sử dụng ở đây
        final newPath = weatherImageService.getBackgroundImageForWeather(
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
  // Xóa bỏ hoàn toàn khối ref.listen ở đây
  final getSuggestionUseCase = ref.watch(getOutfitSuggestionUseCaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return HomePageNotifier(getSuggestionUseCase, notificationService, ref);
});