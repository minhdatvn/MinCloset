// test/home_page_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/home_page_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:mocktail/mocktail.dart';

// 1. Tạo các lớp Mock cho TẤT CẢ các phụ thuộc
class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockWeatherService extends Mock implements WeatherService {}
class MockSuggestionService extends Mock implements SuggestionService {} // <<< THÊM MOCK NÀY

void main() {
  group('HomePageNotifier Tests', () {
    // Khai báo các biến mock và container ở đây để có thể tái sử dụng trong các bài test khác
    late MockDatabaseHelper mockDbHelper;
    late MockWeatherService mockWeatherService;
    late MockSuggestionService mockSuggestionService;
    late ProviderContainer container;
    
    // Dùng setUp để khởi tạo các đối tượng trước mỗi bài test
    setUp(() {
      // Khởi tạo các mock
      mockDbHelper = MockDatabaseHelper();
      mockWeatherService = MockWeatherService();
      mockSuggestionService = MockSuggestionService();

      // Dữ liệu thời tiết giả
      final fakeWeatherData = {
        'name': 'Da Nang',
        'weather': [{'icon': '01d', 'description': 'trời quang'}],
        'main': {'temp': 30.0}
      };

      // Thiết lập hành vi giả lập cho các mock
      when(() => mockDbHelper.getAllItems()).thenAnswer((_) async => []);
      when(() => mockWeatherService.getWeather('Da Nang')).thenAnswer((_) async => fakeWeatherData);
      // Chúng ta không cần thiết lập hành vi cho mockSuggestionService vì nó không được gọi trong kịch bản này

      // Tạo ProviderContainer và ghi đè TẤT CẢ các provider phụ thuộc
      container = ProviderContainer(
        overrides: [
          dbHelperProvider.overrideWithValue(mockDbHelper),
          weatherServiceProvider.overrideWithValue(mockWeatherService),
          // <<< THÊM VIỆC GHI ĐÈ PROVIDER NÀY
          suggestionServiceProvider.overrideWithValue(mockSuggestionService),
        ],
      );
    });

    test('Khi tủ đồ trống, suggestion phải là thông báo phù hợp', () async {
      // --- ARRANGE (SẮP XẾP) ---
      // Phần sắp xếp đã được thực hiện trong `setUp`

      // --- ACT (HÀNH ĐỘNG) ---
      // Chỉ cần đọc provider để kích hoạt nó.
      // Không cần gán vào biến nếu không dùng đến.
      container.read(homeProvider);
      
      // Đợi một chút để các hàm async bên trong notifier chạy xong
      await Future.delayed(const Duration(milliseconds: 10));

      // --- ASSERT (KIỂM CHỨNG) ---
      final finalState = container.read(homeProvider);

      // Kiểm tra các giá trị cuối cùng của state
      expect(finalState.isLoading, isFalse, reason: 'isLoading phải là false sau khi tải xong');
      expect(finalState.errorMessage, isNull, reason: 'errorMessage phải là null khi thành công');
      expect(finalState.suggestion, 'Hãy thêm đồ vào tủ để nhận gợi ý.');
      expect(finalState.weather, isNotNull, reason: 'Dữ liệu thời tiết không được null');
    });
  });
}