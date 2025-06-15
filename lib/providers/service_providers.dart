// lib/providers/service_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/services/suggestion_service.dart';
import 'package:mincloset/services/weather_service.dart';

// Provider này sẽ tạo và cung cấp một đối tượng (instance) của WeatherService
// cho bất kỳ nơi nào trong ứng dụng cần đến nó.
// Đây là cách chúng ta áp dụng Dependency Injection.
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

// Tương tự, provider này cung cấp một đối tượng của SuggestionService.
final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService();
});