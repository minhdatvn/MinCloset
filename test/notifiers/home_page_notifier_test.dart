// test/notifiers/home_page_notifier_test.dart

import 'dart:async'; // <<< SỬA LỖI 2: Thêm import cần thiết
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tạo một lớp Mock cho UseCase
class MockGetOutfitSuggestionUseCase extends Mock
    implements GetOutfitSuggestionUseCase {}

// <<< SỬA LỖI 1: Thêm () cho hàm main >>>
void main() {
  final tWeather = {
    'name': 'Da Nang',
    'main': {'temp': 30.0},
    'weather': [{'description': 'clear sky', 'icon': '01d'}]
  };

  late MockGetOutfitSuggestionUseCase mockGetOutfitSuggestionUseCase;
  
  setUp(() {
    mockGetOutfitSuggestionUseCase = MockGetOutfitSuggestionUseCase();
    
    when(() => mockGetOutfitSuggestionUseCase.getWeatherForSuggestion())
        .thenAnswer((_) async => tWeather);
  });

  test(
      'Khi khởi tạo, Notifier nên tải dữ liệu từ cache và tự động làm mới thời tiết',
      () async {
    // SẮP XẾP (Arrange)
    SharedPreferences.setMockInitialValues({
      'last_suggestion_text': 'Cached Suggestion',
      'last_suggestion_timestamp': DateTime(2025, 6, 25).toIso8601String(),
      'last_weather_data': json.encode(tWeather),
    });

    final container = ProviderContainer(
      overrides: [
        getOutfitSuggestionUseCaseProvider
            .overrideWithValue(mockGetOutfitSuggestionUseCase),
      ],
    );

    // HÀNH ĐỘNG (Act)
    final completer = Completer<void>();
    container.listen(
      homeProvider,
      (previous, next) {
        if (next.weather != null && previous?.weather != next.weather) {
           if (!completer.isCompleted) completer.complete();
        }
      },
      fireImmediately: true,
    );

    // <<< SỬA LỖI 3: Bỏ gán biến không sử dụng >>>
    container.read(homeProvider.notifier);
    await completer.future;

    // KIỂM CHỨNG (Assert)
    final state = container.read(homeProvider);

    expect(state.suggestion, 'Cached Suggestion');
    expect(state.suggestionTimestamp, DateTime(2025, 6, 25));
    verify(() => mockGetOutfitSuggestionUseCase.getWeatherForSuggestion()).called(1);
    expect(state.weather, tWeather);

    container.dispose();
  });

  test(
      'Khi gọi getNewSuggestion, Notifier nên gọi use case và cập nhật state',
      () async {
    // SẮP XẾP (Arrange)
    SharedPreferences.setMockInitialValues({});
    
    final fullSuggestionResult = {
      'weather': tWeather,
      'suggestion': 'New AI Suggestion',
    };
    
    when(() => mockGetOutfitSuggestionUseCase.execute())
        .thenAnswer((_) async => fullSuggestionResult);

    final container = ProviderContainer(
      overrides: [
        getOutfitSuggestionUseCaseProvider
            .overrideWithValue(mockGetOutfitSuggestionUseCase),
      ],
    );
    final notifier = container.read(homeProvider.notifier);

    // HÀNH ĐỘNG (Act)
    await notifier.getNewSuggestion();

    // KIỂM CHỨNG (Assert)
    final state = container.read(homeProvider);

    verify(() => mockGetOutfitSuggestionUseCase.execute()).called(1);
    expect(state.suggestion, 'New AI Suggestion');
    expect(state.weather, tWeather);
    expect(state.isLoading, isFalse);

    container.dispose();
  });
}