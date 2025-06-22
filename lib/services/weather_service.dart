// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/utils/logger.dart';

class WeatherService {
  final String _apiKey;
  
  // <<< THAY ĐỔI: Chuyển host và path ra thành hằng số >>>
  static const _weatherApiHost = 'api.openweathermap.org';
  static const _weatherApiPath = '/data/2.5/weather';
  static const _geoApiPath = '/geo/1.0/direct';

  final http.Client _client;

  WeatherService({required String apiKey, http.Client? client})
      : _apiKey = apiKey,
        _client = client ?? http.Client();

  Future<Map<String, dynamic>> getWeather(String city) async {
    // <<< THAY ĐỔI: Dùng Uri.https để tạo URL an toàn >>>
    final uri = Uri.https(_weatherApiHost, _weatherApiPath, {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'vi',
    });

    try {
      final response = await _client.get(uri); // Sử dụng uri đã tạo
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        logger.w('Lỗi tải dữ liệu thời tiết cho "$city": ${response.statusCode} ${response.body}');
        throw Exception('Failed to load weather data.');
      }
    } catch (error) {
      logger.e('Lỗi kết nối dịch vụ thời tiết', error: error);
      throw Exception('Failed to connect to the weather service.');
    }
  }

  Future<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) async {
    // <<< THAY ĐỔI: Dùng Uri.https để tạo URL an toàn >>>
    final uri = Uri.https(_weatherApiHost, _weatherApiPath, {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'vi',
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        logger.w('Lỗi tải dữ liệu thời tiết cho tọa độ ($lat, $lon): ${response.statusCode} ${response.body}');
        throw Exception('Failed to load weather data by coords.');
      }
    } catch (error) {
      logger.e('Lỗi kết nối dịch vụ thời tiết theo tọa độ', error: error);
      throw Exception('Failed to connect to the weather service.');
    }
  }

  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty) {
      return [];
    }
    // <<< THAY ĐỔI: Dùng Uri.https để tạo URL an toàn >>>
    final uri = Uri.https(_weatherApiHost, _geoApiPath, {
      'q': query,
      'limit': '5',
      'appid': _apiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results
            .map((data) => CitySuggestion.fromMap(data))
            .toList();
      } else {
        logger.w('Lỗi tìm kiếm thành phố cho "$query": ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      logger.e('Lỗi kết nối dịch vụ Geocoding', error: error);
      return [];
    }
  }
}