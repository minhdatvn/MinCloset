// lib/repositories/weather_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository(this._weatherService);

  Future<Either<Failure, Map<String, dynamic>>> getWeather(String city) {
    return _weatherService.getWeather(city);
  }

  Future<Either<Failure, Map<String, dynamic>>> getWeatherByCoords(double lat, double lon) {
    return _weatherService.getWeatherByCoords(lat, lon);
  }
}