// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mincloset/models/city_suggestion.dart'; // <<< THÊM IMPORT MỚI
import 'package:mincloset/utils/logger.dart'; // <<< THÊM IMPORT MỚI

class WeatherService {
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? 'API_KEY_NOT_FOUND';
  static const _baseWeatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  // <<< THÊM URL CHO GECODING API >>>
  static const _baseGeoUrl = 'http://api.openweathermap.org/geo/1.0/direct';

  // Phương thức lấy thời tiết theo tên thành phố (giữ nguyên)
  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = '$_baseWeatherUrl?q=$city&appid=$_apiKey&units=metric&lang=vi';
    try {
      final response = await http.get(Uri.parse(url));
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

  // <<< THÊM PHƯƠNG THỨC MỚI: LẤY THỜI TIẾT THEO TỌA ĐỘ >>>
  Future<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) async {
    final url = '$_baseWeatherUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=vi';
    try {
      final response = await http.get(Uri.parse(url));
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

  // <<< THÊM PHƯƠNG THỨC MỚI: TÌM KIẾM THÀNH PHỐ >>>
  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty) {
      return [];
    }
    // Giới hạn 5 kết quả để tránh làm rối giao diện
    final url = '$_baseGeoUrl?q=$query&limit=5&appid=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results
            .map((data) => CitySuggestion.fromMap(data))
            .toList();
      } else {
        logger.w('Lỗi tìm kiếm thành phố cho "$query": ${response.statusCode} ${response.body}');
        return []; // Trả về danh sách rỗng nếu có lỗi
      }
    } catch (error) {
      logger.e('Lỗi kết nối dịch vụ Geocoding', error: error);
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }
}