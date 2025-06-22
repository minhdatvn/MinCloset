// test/services/weather_service_test.dart

import 'dart:convert'; // Cần cho hàm utf8.encode
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/services/weather_service.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late WeatherService weatherService;
  late MockHttpClient mockHttpClient;
  const tApiKey = 'fake_api_key';

  setUp(() {
    mockHttpClient = MockHttpClient();
    weatherService = WeatherService(apiKey: tApiKey, client: mockHttpClient);
  });

  void mockGetRequestSuccess(Uri uri, String jsonResponse) {
    when(() => mockHttpClient.get(uri))
      // ===================================================================
      // >> THAY ĐỔI DUY NHẤT NẰM Ở ĐÂY <<
      //
      // Thay vì dùng http.Response, chúng ta dùng http.Response.bytes
      // và mã hóa chuỗi JSON thành UTF-8.
      // ===================================================================
      .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonResponse), 200, 
          headers: {'content-type': 'application/json; charset=utf-8'})
      );
  }

  void mockGetRequestFailure(Uri uri, int statusCode) {
    when(() => mockHttpClient.get(uri))
        .thenAnswer((_) async => http.Response('Not Found', statusCode));
  }

  group('getWeather', () {
    const tCity = 'Da Nang';
    // Chuỗi JSON vẫn giữ nguyên, không thay đổi
    final tWeatherJson = '{"coord":{"lon":108.22,"lat":16.07},"weather":[{"id":800,"main":"Clear","description":"trời quang","icon":"01n"}],"main":{"temp":27.99}}';

    final tUri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': tCity,
      'appid': tApiKey,
      'units': 'metric',
      'lang': 'vi',
    });

    test('Nên trả về một Map thời tiết khi lệnh gọi API thành công (status code 200)', () async {
      mockGetRequestSuccess(tUri, tWeatherJson);
      final result = await weatherService.getWeather(tCity);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['main']['temp'], 27.99);
    });

    test('Nên ném ra một Exception khi lệnh gọi API thất bại (status code không phải 200)', () async {
      mockGetRequestFailure(tUri, 404);
      expect(() => weatherService.getWeather(tCity), throwsA(isA<Exception>()));
    });
  });

  group('searchCities', () {
    const tQuery = 'London';
    final tCitySuggestionJson = '[{"name":"London","lat":51.5073,"lon":-0.1276,"country":"GB"}]';

    final tUri = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': tQuery,
      'limit': '5',
      'appid': tApiKey,
    });

    test('Nên trả về một List<CitySuggestion> khi lệnh gọi API thành công', () async {
      mockGetRequestSuccess(tUri, tCitySuggestionJson);
      final result = await weatherService.searchCities(tQuery);
      expect(result, isA<List<CitySuggestion>>());
      expect(result.first.name, 'London');
    });

    test('Nên trả về một danh sách rỗng khi lệnh gọi API thất bại', () async {
      mockGetRequestFailure(tUri, 500);
      final result = await weatherService.searchCities(tQuery);
      expect(result, isEmpty);
    });
  });
}