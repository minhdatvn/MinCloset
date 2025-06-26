// lib/repositories/weather_repository.dart
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository(this._weatherService);

  FutureEither<Map<String, dynamic>> getWeather(String city) {
    return _weatherService.getWeather(city);
  }

  FutureEither<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) {
    return _weatherService.getWeatherByCoords(lat, lon);
  }
}