// lib/notifiers/home_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  HomePageNotifier(this._ref) : super(const HomePageState());

  // <<< HÀM MỚI: Tải gợi ý đã lưu và chỉ lấy thời tiết >>>
  Future<void> loadSavedSuggestion() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSuggestion = prefs.getString('last_suggestion_text');
      final lastTimestampString = prefs.getString('last_suggestion_timestamp');
      final lastTimestamp = lastTimestampString != null ? DateTime.tryParse(lastTimestampString) : null;

      // Chỉ lấy thời tiết mà không gọi AI
      final weatherData = await _ref.read(getOutfitSuggestionUseCaseProvider).getWeatherForSuggestion();
      
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          weather: weatherData,
          suggestion: lastSuggestion, // Hiển thị gợi ý đã lưu
          suggestionTimestamp: lastTimestamp,
        );
      }
    } catch (e, s) {
      logger.e('Lỗi khi tải gợi ý đã lưu', error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: 'Không thể tải dữ liệu.');
      }
    }
  }

  // <<< HÀM CŨ: Giờ chỉ tập trung vào việc lấy gợi ý mới từ AI >>>
  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final getSuggestion = _ref.read(getOutfitSuggestionUseCaseProvider);
      // Giờ đây getSuggestion.execute() sẽ chỉ gọi AI và thời tiết
      final result = await getSuggestion.execute();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_suggestion_text', result['suggestion'] as String);
      final now = DateTime.now();
      await prefs.setString('last_suggestion_timestamp', now.toIso8601String());

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          weather: result['weather'] as Map<String, dynamic>?,
          suggestion: result['suggestion'] as String?,
          suggestionTimestamp: now,
        );
      }
    } catch (e, s) {
      logger.e('Lỗi khi lấy gợi ý mới', error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: 'Không thể nhận gợi ý. Vui lòng thử lại.');
      }
    }
  }
}

// Provider không đổi
final homeProvider = StateNotifierProvider.autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});