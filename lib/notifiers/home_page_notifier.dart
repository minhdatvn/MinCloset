// lib/notifiers/home_page_notifier.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  // Sửa đổi constructor: gọi hàm init() mới
  HomePageNotifier(this._ref) : super(const HomePageState()) {
    init();
  }

  // Hàm init: Tải dữ liệu đã lưu và làm mới thời tiết
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Đọc dữ liệu đã lưu từ bộ nhớ
    final lastSuggestion = prefs.getString('last_suggestion_text');
    final lastTimestampString = prefs.getString('last_suggestion_timestamp');
    final lastWeatherString = prefs.getString('last_weather_data');

    Map<String, dynamic>? lastWeather;
    if (lastWeatherString != null) {
      try {
        lastWeather = json.decode(lastWeatherString) as Map<String, dynamic>;
      } catch (e) {
        logger.w('Could not parse last weather data from cache.');
      }
    }
    
    final lastTimestamp = lastTimestampString != null
        ? DateTime.tryParse(lastTimestampString)
        : null;

    // Cập nhật state với dữ liệu đã lưu
    state = state.copyWith(
      suggestion: lastSuggestion,
      suggestionTimestamp: lastTimestamp,
      weather: lastWeather,
      isLoading: false, // Bắt đầu với không loading
    );

    // Sau khi tải cache, tự động làm mới chỉ riêng thời tiết
    // (Chúng ta sẽ hoàn thiện hàm này ở bước sau)
    await refreshWeatherOnly(); 
  }

  // Hàm mới: Chỉ làm mới thời tiết
  Future<void> refreshWeatherOnly() async {
    logger.i("Weather refresh triggered.");
    try {
      final getSuggestionUseCase = _ref.read(getOutfitSuggestionUseCaseProvider);
      // Gọi hàm public mới từ use case
      final weatherData = await getSuggestionUseCase.getWeatherForSuggestion();

      if (mounted) {
        // Chỉ cập nhật thời tiết, giữ nguyên gợi ý cũ
        state = state.copyWith(weather: weatherData);
      }
    } catch (e, s) {
      logger.e('Failed to refresh weather only', error: e, stackTrace: s);
      // Không cần hiển thị lỗi cho người dùng ở bước tự động này
    }
  }

  // Cập nhật hàm getNewSuggestion để lưu cả dữ liệu thời tiết
  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final getSuggestion = _ref.read(getOutfitSuggestionUseCaseProvider);
      final result = await getSuggestion.execute();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_suggestion_text', result['suggestion'] as String);
      await prefs.setString('last_suggestion_timestamp', DateTime.now().toIso8601String());
      
      // Lưu trữ weather data dưới dạng JSON string
      if (result['weather'] != null) {
        await prefs.setString('last_weather_data', json.encode(result['weather']));
      }

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          weather: result['weather'] as Map<String, dynamic>?,
          suggestion: result['suggestion'] as String?,
          suggestionTimestamp: DateTime.now(),
        );
      }
    } catch (e, s) {
      logger.e('Failed to get new suggestions', error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to get suggestions. Please try again.',
        );
      }
    }
  }
}

// Bỏ .autoDispose để giữ state khi chuyển trang
final homeProvider = StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});