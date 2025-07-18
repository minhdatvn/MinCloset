// lib/services/weather_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mincloset/services/secure_storage_service.dart';

class WeatherService {
  // 2. Xóa biến _apiKey và thay đổi constructor
  // Giờ đây nó phụ thuộc vào SecureStorageService
  final SecureStorageService _secureStorage;
  final http.Client _client;
  
  static const _weatherApiHost = 'api.openweathermap.org';
  static const _weatherApiPath = '/data/2.5/weather';
  static const _geoApiPath = '/geo/1.0/direct';

  WeatherService({required SecureStorageService secureStorage, http.Client? client})
      : _secureStorage = secureStorage,
        _client = client ?? http.Client();

  // 3. Tạo một hàm helper riêng để lấy API key
  // Giúp tránh lặp lại code và xử lý lỗi tập trung.
  Future<String> _getApiKey() async {
    final apiKey = await _secureStorage.read(SecureStorageKeys.openWeatherApiKey);
    if (apiKey == null || apiKey.isEmpty) {
      // Ném ra lỗi nếu không tìm thấy key, các hàm gọi sẽ bắt lỗi này
      throw Exception('OpenWeather API key not found in secure storage.');
    }
    return apiKey;
  }

  FutureEither<Map<String, dynamic>> getWeather(String city) async {
    try {
      // 4. Gọi hàm helper để lấy key
      final apiKey = await _getApiKey();
      final uri = Uri.https(_weatherApiHost, _weatherApiPath, {
        'q': city,
        'appid': apiKey, // Sử dụng key vừa lấy được
        'units': 'metric',
        'lang': 'vi',
      });

      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        return Right(json.decode(response.body));
      } else {
        logger.w('Lỗi tải dữ liệu thời tiết cho "$city": ${response.statusCode} ${response.body}');
        return Left(ServerFailure('Failed to load weather data. Status code: ${response.statusCode}'));
      }
    } on SocketException {
        return const Left(NetworkFailure('Please check your internet connection.'));
    } catch (e, s) {
        logger.e('Lỗi không xác định trong getWeather', error: e, stackTrace: s);
        Sentry.captureException(e, stackTrace: s);
        return Left(GenericFailure(e.toString()));
    }
  }

  FutureEither<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) async {
    try {
      // 5. Sử dụng lại hàm helper ở đây
      final apiKey = await _getApiKey();
      final uri = Uri.https( _weatherApiHost, _weatherApiPath, {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey, // Sử dụng key vừa lấy được
        'units': 'metric',
        'lang': 'vi',
      });
      
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        return Right(json.decode(response.body));
      } else {
        logger.w('Lỗi tải dữ liệu thời tiết cho tọa độ ($lat, $lon): ${response.statusCode} ${response.body}');
        return Left(ServerFailure('Failed to load weather data by coords. Status code: ${response.statusCode}'));
      }
    } on SocketException {
        return const Left(NetworkFailure('Please check your internet connection.'));
    } catch (e, s) {
        logger.e('Lỗi không xác định trong getWeatherByCoords', error: e, stackTrace: s);
        Sentry.captureException(e, stackTrace: s);
        return Left(GenericFailure(e.toString()));
    }
  }

  FutureEither<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty) {
      return const Right([]);
    }
    try {
      // 6. Và sử dụng lại hàm helper ở đây
      final apiKey = await _getApiKey();
      final uri = Uri.https(_weatherApiHost, _geoApiPath, {
        'q': query,
        'limit': '5',
        'appid': apiKey, // Sử dụng key vừa lấy được
      });
      
      final response = await _client.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        final suggestions = results
            .map((data) => CitySuggestion.fromMap(data))
            .toList();
        return Right(suggestions);
      } else {
        logger.w('Lỗi tìm kiếm thành phố cho "$query": ${response.statusCode} ${response.body}');
        return Left(ServerFailure('Failed to search for cities. Status code: ${response.statusCode}'));
      }
    } on SocketException {
        return const Left(NetworkFailure('Please check your internet connection.'));
    } catch (e, s) {
        logger.e('Lỗi không xác định trong searchCities', error: e, stackTrace: s);
        Sentry.captureException(e, stackTrace: s);
        return Left(GenericFailure(e.toString()));
    }
  }
}