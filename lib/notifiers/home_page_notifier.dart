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
import 'package:mincloset/l10n/app_localizations.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final GetOutfitSuggestionUseCase _getSuggestionUseCase;
  final NotificationService _notificationService;
  final Ref _ref;

  HomePageNotifier(
      this._getSuggestionUseCase, this._notificationService, this._ref)
      : super(const HomePageState()) {
    init();
    _ref.listen<ProfilePageState>(profileProvider, (previous, next) {
      // Kiểm tra xem các giá trị liên quan đến vị trí có thực sự thay đổi không
      if (previous != null && (previous.cityMode != next.cityMode || previous.manualCity != next.manualCity)) {
        // Ghi log để debug (tùy chọn)
        logger.i("Location settings changed, triggering weather refresh.");
        
        // Gọi hàm làm mới thời tiết đã có sẵn của notifier này
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
            if (failure.message == 'error_noNetworkConnection') {
              state = state.copyWith(
                isLoading: false,
                weather: null,
                errorMessage: failure.message,
                backgroundImagePath: 'assets/images/weather_backgrounds/default_1.webp',
              );
            }
          },
          (weatherData) {
          final newPath = weatherImageService.getBackgroundImageForWeather(
                weatherData['weather'][0]['icon'] as String?);
            state = state.copyWith(
              weather: weatherData,
              backgroundImagePath: newPath,
              clearError: true // Xóa lỗi cũ nếu lần này thành công
            );
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

  Future<void> getNewSuggestion({String? purpose, required AppLocalizations l10n}) async {
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
        if (failure.message == 'error_noNetworkConnection') {
          // Nếu là lỗi mạng, cập nhật state để UI hiển thị thông báo
          state = state.copyWith(
              isLoading: false,
              weather: null,
              errorMessage: failure.message
          );
        } else {
          // Các lỗi khác thì vẫn hiện banner như cũ
          String translatedError = _translateErrorCode(failure.message, l10n);
          _notificationService.showBanner(message: translatedError);
          state = state.copyWith(isLoading: false);
        }
      },
      (result) async { //Chuyển thành hàm async
        //Bắt lấy kết quả và phát tín hiệu
        final completedQuests = await _ref.read(questRepositoryProvider).updateQuestProgress(QuestEvent.suggestionReceived);
        if (completedQuests.isNotEmpty && mounted) {
            _ref.read(completedQuestProvider.notifier).state = completedQuests.first;
        }

        final weatherData = result['weather'] as Map<String, dynamic>?;
        if (weatherData != null && weatherData['name'] == null) {
          weatherData['name'] = l10n.getOutfitSuggestion_defaultCurrentLocation;
        } else if (weatherData != null && weatherData['name'] == 'Selected Location') {
          // Lưu ý: Chuỗi 'Selected Location' này là giá trị cũ, chúng ta sẽ thay thế nó.
          // Trong UseCase, chúng ta đã trả về tên thành phố thật sự, nên dòng này có thể không cần thiết nữa
          // nhưng để đây để đảm bảo tính tương thích ngược.
          weatherData['name'] = l10n.getOutfitSuggestion_defaultSelectedLocation;
        }
        
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

  String _translateErrorCode(String code, AppLocalizations l10n) {
      switch (code) {
        case 'GetOutfitSuggestion_error_manualLocationMissing':
          return l10n.getOutfitSuggestion_errorManualLocationMissing;
        case 'GetOutfitSuggestion_error_locationServicesDisabled':
          return l10n.getOutfitSuggestion_errorLocationServicesDisabled;
        case 'GetOutfitSuggestion_error_locationPermissionDenied':
          return l10n.getOutfitSuggestion_errorLocationPermissionDenied;
        case 'GetOutfitSuggestion_error_locationUndetermined':
          return l10n.getOutfitSuggestion_errorLocationUndetermined;
        case 'GetOutfitSuggestion_error_notEnoughItems':
          return l10n.getOutfitSuggestion_errorNotEnoughItems;
        default:
          return code; // Trả về chính mã lỗi nếu không tìm thấy bản dịch
      }
  }
}

final homeProvider =
    StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  final getSuggestionUseCase = ref.watch(getOutfitSuggestionUseCaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return HomePageNotifier(getSuggestionUseCase, notificationService, ref);
});