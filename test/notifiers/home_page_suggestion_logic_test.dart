// test/notifiers/home_page_logic_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mocktail/mocktail.dart';

// ---- PHẦN THIẾT LẬP MOCK (Không thay đổi) ----
class MockHomePageNotifier extends StateNotifier<HomePageState>
    with Mock
    implements HomePageNotifier {
  MockHomePageNotifier(super.state);
}

class MockProfilePageNotifier extends StateNotifier<ProfilePageState>
    with Mock
    implements ProfilePageNotifier {
  MockProfilePageNotifier(super.state);
}

void main() {
  late MockHomePageNotifier mockHomeNotifier;
  late MockProfilePageNotifier mockProfileNotifier;

  setUp(() {
    mockHomeNotifier = MockHomePageNotifier(const HomePageState());
    mockProfileNotifier = MockProfilePageNotifier(const ProfilePageState());
    when(() => mockHomeNotifier.getNewSuggestion()).thenAnswer((_) async {});
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        homeProvider.overrideWith((ref) => mockHomeNotifier),
        profileProvider.overrideWith((ref) => mockProfileNotifier),
        recentItemsProvider.overrideWith((ref) => Future.value([])),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: HomePage(),
        ),
      ),
    );
  }

  group('HomePage Suggestion Logic Test', () {
    
    testWidgets('Không nên gọi getNewSuggestion khi HomePage được build', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      verifyNever(() => mockHomeNotifier.getNewSuggestion());
    });

    testWidgets('Nên gọi getNewSuggestion khi nhấn nút "Gợi ý mới"', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      // <<< SỬA LỖI Ở ĐÂY: Tìm bằng Key >>>
      final buttonFinder = find.byKey(const ValueKey('new_suggestion_button'));
      expect(buttonFinder, findsOneWidget);

      // Đảm bảo nút có thể nhìn thấy được trước khi nhấn (tự động cuộn nếu cần)
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();

      // Nhấn vào nút đã tìm thấy
      await tester.tap(buttonFinder);
      await tester.pump();

      verify(() => mockHomeNotifier.getNewSuggestion()).called(1);
    });

    testWidgets('Không nên gọi getNewSuggestion khi thực hiện pull-to-refresh', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      final refreshIndicator = tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      await refreshIndicator.onRefresh();
      await tester.pump();

      verifyNever(() => mockHomeNotifier.getNewSuggestion());
    });
  });
}