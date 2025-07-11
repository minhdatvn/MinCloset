// lib/repositories/city_repository.dart

import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/services/weather_service.dart';

class CityRepository {
  final WeatherService _weatherService;

  CityRepository(this._weatherService);

  FutureEither<List<CitySuggestion>> searchCities(String query) {
    // Repository chỉ đơn giản là gọi đến service tương ứng
    return _weatherService.searchCities(query);
  }
}