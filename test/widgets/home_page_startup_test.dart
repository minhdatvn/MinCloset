// test/widgets/home_page_startup_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mocktail/mocktail.dart';

// Các lớp Mock
class MockGetOutfitSuggestionUseCase extends Mock implements GetOutfitSuggestionUseCase {}
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
  testWidgets('Không tự động gọi gợi ý khi khởi động', (WidgetTester tester) async {
    // Arrange
    final mockUseCase = MockGetOutfitSuggestionUseCase();
    when(() => mockUseCase.execute()).thenThrow(TestFailure('Không được gọi!'));
    when(() => mockUseCase.getWeatherForSuggestion()).thenThrow(TestFailure('Không được gọi!'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getOutfitSuggestionUseCaseProvider.overrideWithValue(mockUseCase),
          profileProvider.overrideWith((ref) => TestProfileNotifier()),
          recentItemsProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    verifyNever(() => mockUseCase.execute());
    expect(find.text('Press "New Suggestion" and let MinCloset advise you!'), findsOneWidget);
  });
}