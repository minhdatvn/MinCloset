// test/widgets/home_page_suggestion_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mocktail/mocktail.dart';

// --- MOCKING STRATEGY MỚI ---
// 1. Tạo một lớp Mock kế thừa từ StateNotifier và implements Notifier thật
// Điều này cho phép chúng ta vừa có một StateNotifier, vừa có thể giả lập các hàm của nó.
class MockHomePageNotifier extends StateNotifier<HomePageState> with Mock implements HomePageNotifier {
  MockHomePageNotifier() : super(const HomePageState());

  // Chúng ta không cần định nghĩa lại các hàm getNewSuggestion hay loadSavedSuggestion
  // vì `with Mock` đã tự động xử lý chúng.
}

// Lớp mock cho ProfileNotifier vẫn giữ nguyên
class TestProfileNotifier extends StateNotifier<ProfilePageState> implements ProfilePageNotifier {
  TestProfileNotifier() : super(const ProfilePageState(isLoading: false));
  @override
  Future<void> loadInitialData() async {}
  @override
  Future<void> updateAvatar() async {}
  @override
  Future<void> updateCityPreference(mode, suggestion) async {}
  @override
  Future<void> updateProfileInfo(data) async {}
}

void main() {
  late MockHomePageNotifier mockHomePageNotifier;

  // Hàm helper để bơm widget
  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 2. Override trực tiếp homeProvider bằng Notifier giả của chúng ta
          homeProvider.overrideWith((ref) => mockHomePageNotifier),
          profileProvider.overrideWith((ref) => TestProfileNotifier()),
          recentItemsProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
  }

  group('HomePage Suggestion Logic', () {
    // Chạy trước mỗi test
    setUp(() {
      // Khởi tạo Notifier giả
      mockHomePageNotifier = MockHomePageNotifier();
    });

    testWidgets('Khi nhấn nút, UI nên cập nhật đúng với state từ Notifier', (WidgetTester tester) async {
      // --- ARRANGE ---
      const expectedText = 'Gợi ý đã được cập nhật bởi mock!';
      
      // Giả lập rằng khi hàm getNewSuggestion được gọi, nó không làm gì cả
      // vì chúng ta sẽ tự cập nhật state.
      when(() => mockHomePageNotifier.getNewSuggestion()).thenAnswer((_) async {});

      await pumpHomePage(tester);
      await tester.pumpAndSettle();

      // --- ACT ---
      final buttonFinder = find.text('New Suggestion');
      await tester.ensureVisible(buttonFinder);

      // Nhấn nút, hành động này sẽ gọi đến hàm getNewSuggestion giả của chúng ta
      await tester.tap(buttonFinder);
      await tester.pump(); // Pump để xử lý hành động tap

      // --- SIMULATE STATE CHANGE ---
      // Đây là bước quan trọng: chúng ta tự tay thay đổi state của Notifier giả
      mockHomePageNotifier.state = mockHomePageNotifier.state.copyWith(
        isLoading: false,
        suggestion: expectedText,
      );
      
      // Pump thêm một lần nữa để UI nhận state mới và build lại
      await tester.pump();

      // --- ASSERT ---
      // 1. Xác minh rằng hàm getNewSuggestion đã được gọi
      verify(() => mockHomePageNotifier.getNewSuggestion()).called(1);
      
      // 2. Kiểm tra UI đã hiển thị đúng state mà chúng ta đã gán
      expect(find.text(expectedText), findsOneWidget);
    });
  });
}