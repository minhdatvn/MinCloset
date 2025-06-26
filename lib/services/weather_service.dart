// lib/services/weather_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:mincloset/domain/core/type_defs.dart'; // <<< THÊM DÒNG NÀY
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class WeatherService {
  final String _apiKey;
  
  static const _weatherApiHost = 'api.openweathermap.org';
  static const _weatherApiPath = '/data/2.5/weather';
  static const _geoApiPath = '/geo/1.0/direct';

  final http.Client _client;

  WeatherService({required String apiKey, http.Client? client})
      : _apiKey = apiKey,
        _client = client ?? http.Client();

  // <<< THAY ĐỔI: Sử dụng typedef >>>
  FutureEither<Map<String, dynamic>> getWeather(String city) async {
    final uri = Uri.https(_weatherApiHost, _weatherApiPath, {
      'q': city,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'vi',
    });

    try {
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

  // <<< THAY ĐỔI: Sử dụng typedef >>>
  FutureEither<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) async {
    final uri = Uri.https( _weatherApiHost, _weatherApiPath, {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'vi',
    });

    try {
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

  // <<< THAY ĐỔI: Sử dụng typedef >>>
  FutureEither<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty) {
      return const Right([]);
    }
    final uri = Uri.https(_weatherApiHost, _geoApiPath, {
      'q': query,
      'limit': '5',
      'appid': _apiKey,
    });

    try {
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