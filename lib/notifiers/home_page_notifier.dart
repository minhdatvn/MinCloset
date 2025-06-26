// lib/notifiers/home_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  // Sửa đổi constructor: gọi hàm init() mới
  HomePageNotifier(this._ref) : super(const HomePageState()) {
    init();
  }

  // SỬA LẠI HÀM INIT
  Future<void> init() async {
    // Tạm thời, khi khởi tạo, chúng ta chỉ làm mới thời tiết.
    // Logic cache sẽ được thêm lại một cách hoàn chỉnh sau.
    await refreshWeatherOnly();
  }

  Future<void> refreshWeatherOnly() async {
    logger.i("Weather refresh triggered.");
    try {
      final getSuggestionUseCase = _ref.read(getOutfitSuggestionUseCaseProvider);
      final weatherData = await getSuggestionUseCase.getWeatherForSuggestion();

      if (mounted) {
        state = state.copyWith(weather: weatherData);
      }
    } catch (e, s) {
      logger.e('Failed to refresh weather only', error: e, stackTrace: s);
    }
  }

  // SỬA LẠI HÀM GETNEWSUGGESTION
  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final getSuggestion = _ref.read(getOutfitSuggestionUseCaseProvider);
      final result = await getSuggestion.execute();

      // Bỏ biến `prefs` không sử dụng
      
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          suggestionResult: result['suggestionResult'] as SuggestionResult?,
          weather: result['weather'] as Map<String, dynamic>?,
          suggestionTimestamp: DateTime.now(),
          suggestionId: state.suggestionId + 1,
        );
      }
    } catch (e, s) {
      logger.e('Failed to get new suggestions', error: e, stackTrace: s);
  
      // Gọi service để hiển thị banner lỗi
      _ref.read(notificationServiceProvider).showBanner(
        message: e.toString().replaceAll("Exception: ", "")
      );

      if (mounted) {
        // Chỉ cần tắt trạng thái loading, không cần set errorMessage nữa
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

// Provider giữ nguyên
final homeProvider = StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});