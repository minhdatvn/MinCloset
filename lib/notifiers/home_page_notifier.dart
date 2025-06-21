// lib/notifiers/home_page_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  HomePageNotifier(this._ref) : super(const HomePageState()) {
    // <<< THAY ĐỔI: Gọi getNewSuggestion() ngay khi khởi tạo >>>
    // Điều này đảm bảo app luôn có dữ liệu mới nhất khi mở
    getNewSuggestion();
  }

  // <<< XÓA BỎ HOÀN TOÀN HÀM loadInitialData() >>>

  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final getSuggestion = _ref.read(getOutfitSuggestionUseCaseProvider);
      final result = await getSuggestion.execute();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_suggestion_text', result['suggestion']);
      await prefs.setString(
          'last_suggestion_timestamp', DateTime.now().toIso8601String());

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          weather: result['weather'],
          suggestion: result['suggestion'],
          suggestionTimestamp: DateTime.now(),
        );
      }
    } catch (e, s) {
      logger.e('Lỗi khi lấy gợi ý mới', error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể nhận gợi ý. Vui lòng thử lại.',
        );
      }
    }
  }
}

final homeProvider =
    StateNotifierProvider.autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});