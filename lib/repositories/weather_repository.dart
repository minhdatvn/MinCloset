// lib/repositories/weather_repository.dart
import 'package:mincloset/services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository(this._weatherService);

  Future<Map<String, dynamic>> getWeather(String city) {
    return _weatherService.getWeather(city);
  }
}