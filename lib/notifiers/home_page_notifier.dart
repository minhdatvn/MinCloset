// lib/notifiers/home_page_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/states/home_page_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/providers/repository_providers.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  HomePageNotifier(this._ref) : super(const HomePageState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSuggestion = prefs.getString('last_suggestion_text');
      final lastTimestampString = prefs.getString('last_suggestion_timestamp');
      final lastTimestamp = lastTimestampString != null ? DateTime.parse(lastTimestampString) : null;
      
      // Vẫn tải thời tiết ban đầu để UI hiển thị ngay lập tức
      final weatherRepo = _ref.read(weatherRepositoryProvider);
      final weatherData = await weatherRepo.getWeather('Da Nang');
      
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        weather: weatherData,
        suggestion: lastSuggestion,
        suggestionTimestamp: lastTimestamp,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: "Không thể tải dữ liệu thời tiết.");
    }
  }

  // <<< HÀM NÀY GIỜ RẤT GỌN GÀNG
  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Lấy ra Use Case từ provider
      final getSuggestion = _ref.read(getOutfitSuggestionUseCaseProvider);
      
      // 2. Thực thi Use Case
      final result = await getSuggestion.execute();

      // 3. Lưu kết quả mới
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_suggestion_text', result['suggestion']);
      await prefs.setString('last_suggestion_timestamp', DateTime.now().toIso8601String());

      // 4. Cập nhật state cho UI
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          weather: result['weather'],
          suggestion: result['suggestion'],
          suggestionTimestamp: DateTime.now(),
        );
      }
    } catch (e) {
      // <<< VÀ ĐẶC BIỆT LÀ TRONG KHỐI CATCH
      // Đây chính là nơi gây ra lỗi trong ảnh chụp màn hình của bạn.
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể nhận gợi ý. Vui lòng thử lại.',
          suggestionTimestamp: DateTime.now(),
        );
      }
    }
  }
}

// Provider chính không đổi
final homeProvider = StateNotifierProvider.autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});