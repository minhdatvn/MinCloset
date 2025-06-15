// lib/providers/home_page_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/home_page_state.dart';
// <<< LỖI ĐƯỢC SỬA TẠI ĐÂY: THÊM DÒNG IMPORT NÀY
import 'package:mincloset/providers/service_providers.dart';

// Lớp Notifier kế thừa StateNotifier<Kiểu_Dữ_Liệu_State>
class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref; // Dùng để đọc các provider khác

  // Khởi tạo trạng thái ban đầu
  HomePageNotifier(this._ref) : super(const HomePageState()) {
    fetchSuggestion(); // Tự động gọi hàm lấy dữ liệu khi được tạo
  }

  // Di chuyển toàn bộ logic từ _fetchSuggestion trong widget vào đây
  Future<void> fetchSuggestion() async {
    // Cập nhật state: Bắt đầu loading, xóa lỗi cũ (nếu có)
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // ĐỌC CÁC PROVIDER TỪ REF
      final dbHelper = _ref.read(dbHelperProvider);
      final weatherService = _ref.read(weatherServiceProvider);
      final suggestionService = _ref.read(suggestionServiceProvider);

      // GỌI HÀM TỪ INSTANCE, KHÔNG GỌI STATIC NỮA
      final weatherData = await weatherService.getWeather('Da Nang');

      final itemsData = await dbHelper.getAllItems();
      final items = itemsData.map((map) => ClothingItem.fromMap(map)).toList();

      if (items.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          weather: weatherData,
          suggestion: 'Hãy thêm đồ vào tủ để nhận gợi ý.',
        );
        return;
      }

      final suggestionText = await suggestionService.getOutfitSuggestion(
        weather: weatherData,
        items: items,
      );

      // Cập nhật state: Tải xong, có dữ liệu mới
      state = state.copyWith(
        isLoading: false,
        weather: weatherData,
        suggestion: suggestionText,
      );
    } catch (e) {
      // Cập nhật state: Tải xong, có lỗi
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể nhận gợi ý. Vui lòng thử lại.',
      );
    }
  }
}

// Provider này không thay đổi
final homeProvider = StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref);
});