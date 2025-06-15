// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/main.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/outfit_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// <<< THÊM IMPORT MỚI
import 'package:shared_preferences/shared_preferences.dart';

// Các lớp Mock giữ nguyên
class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockWeatherService extends Mock implements WeatherService {}
class MockSuggestionService extends Mock implements SuggestionService {}

void main() {
  // Khởi tạo FFI cho CSDL
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late MockDatabaseHelper mockDbHelper;
  late MockWeatherService mockWeatherService;
  late MockSuggestionService mockSuggestionService;

  // Dùng setUpAll để thiết lập mock một lần cho tất cả các test trong file này
  setUpAll(() {
    mockDbHelper = MockDatabaseHelper();
    mockWeatherService = MockWeatherService();
    mockSuggestionService = MockSuggestionService();

    // Thiết lập hành vi giả lập chung
    final fakeWeatherData = {
      'name': 'Da Nang',
      'weather': [{'icon': '01d', 'description': 'trời quang'}],
      'main': {'temp': 30.0}
    };
    
    when(() => mockDbHelper.getAllItems()).thenAnswer((_) async => []);
    when(() => mockDbHelper.getRecentItems(any())).thenAnswer((_) async => []);
    when(() => mockDbHelper.getClosets()).thenAnswer((_) async => []);
    when(() => mockDbHelper.getOutfits()).thenAnswer((_) async => []);
    when(() => mockWeatherService.getWeather(any())).thenAnswer((_) async => fakeWeatherData);
  });


  testWidgets('HomePage UI Smoke Test', (WidgetTester tester) async {
    // SẮP XẾP (ARRANGE)
    // <<< BƯỚC 1: GIẢ LẬP SharedPreferences
    // Thiết lập giá trị giả cho SharedPreferences trước khi bơm widget
    SharedPreferences.setMockInitialValues({}); 

    // Bơm widget với các provider đã được ghi đè bằng mock
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbHelperProvider.overrideWithValue(mockDbHelper),
          weatherServiceProvider.overrideWithValue(mockWeatherService),
          suggestionServiceProvider.overrideWithValue(mockSuggestionService),
          // Ghi đè cả provider của outfit để tránh lỗi tiềm ẩn
          outfitsProvider.overrideWith((ref) async => []),
        ],
        child: const MinClosetApp(),
      ),
    );

    // HÀNH ĐỘNG & KIỂM CHỨNG (ACT & ASSERT)

    // Khung hình đầu tiên: SplashScreen được build và hiển thị CircularProgressIndicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: "SplashScreen ban đầu phải hiển thị vòng xoay loading");

    // Bơm một khoảng thời gian để các hàm async trong `_initializeApp` của SplashScreen hoàn thành.
    await tester.pump(const Duration(seconds: 1));

    // Bơm thêm một khung hình nữa để xử lý việc điều hướng từ SplashScreen sang HomePage.
    // Tại thời điểm này, HomePage được build lần đầu, provider của nó bắt đầu hoạt động
    // và HomePage sẽ hiển thị vòng xoay loading của riêng nó.
    await tester.pump();
    
    // Vì các provider của chúng ta đã được mock và trả về dữ liệu ngay lập tức,
    // chúng ta chỉ cần bơm thêm một khung hình cuối cùng để UI cập nhật với dữ liệu đó.
    await tester.pump();
    
    // BÂY GIỜ, giao diện đã ổn định.
    
    // Khẳng định rằng không còn vòng xoay loading nào nữa.
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: "Tất cả loading phải hoàn tất và vòng xoay phải biến mất");

    // Khẳng định rằng các thành phần chính của HomePage đã hiển thị.
    expect(find.text('Xin chào,'), findsOneWidget);
    expect(find.text('AI Stylist'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}