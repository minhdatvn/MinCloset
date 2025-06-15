// lib/notifiers/home_page_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<< THÊM IMPORT NÀY

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;

  HomePageNotifier(this._ref) : super(const HomePageState()) {
    // <<< THAY ĐỔI: Gọi hàm tải dữ liệu ban đầu
    loadInitialData();
  }

  // <<< THÊM HÀM MỚI: Tải dữ liệu ban đầu cho trang chủ
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      // Lấy SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      // Đọc gợi ý và timestamp đã lưu
      final lastSuggestion = prefs.getString('last_suggestion_text');
      final lastTimestampString = prefs.getString('last_suggestion_timestamp');
      final lastTimestamp = lastTimestampString != null ? DateTime.parse(lastTimestampString) : null;

      // Lấy thông tin thời tiết
      final weatherService = _ref.read(weatherServiceProvider);
      final weatherData = await weatherService.getWeather('Da Nang');
      
      // Cập nhật state với dữ liệu ban đầu
      state = state.copyWith(
        isLoading: false,
        weather: weatherData,
        suggestion: lastSuggestion, // Hiển thị gợi ý đã lưu
        suggestionTimestamp: lastTimestamp,
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Không thể tải dữ liệu thời tiết.",
      );
    }
  }

  // Hàm lấy gợi ý mới
  Future<void> getNewSuggestion() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dbHelper = _ref.read(dbHelperProvider);
      final weatherService = _ref.read(weatherServiceProvider);
      final suggestionService = _ref.read(suggestionServiceProvider);

      final weatherData = await weatherService.getWeather('Da Nang');
      final itemsData = await dbHelper.getAllItems();
      final items = itemsData.map((map) => ClothingItem.fromMap(map)).toList();

      if (items.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          weather: weatherData,
          suggestion: 'Hãy thêm đồ vào tủ để nhận gợi ý.',
          suggestionTimestamp: DateTime.now(),
        );
        return;
      }

      final suggestionText = await suggestionService.getOutfitSuggestion(
        weather: weatherData,
        items: items,
      );

      // <<< THÊM LOGIC LƯU GỢI Ý MỚI
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_suggestion_text', suggestionText);
      await prefs.setString('last_suggestion_timestamp', DateTime.now().toIso8601String());

      // Cập nhật state với gợi ý mới
      state = state.copyWith(
        isLoading: false,
        weather: weatherData,
        suggestion: suggestionText,
        suggestionTimestamp: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể nhận gợi ý. Vui lòng thử lại.',
        suggestionTimestamp: DateTime.now(),
      );
    }
  }
}

// Provider không thay đổi
final homeProvider = StateNotifierProvider.autoDispose<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});