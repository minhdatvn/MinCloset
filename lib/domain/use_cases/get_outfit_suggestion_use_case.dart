// lib/domain/use_cases/get_out_suggestion_use_case.dart

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetOutfitSuggestionUseCase {
  final ClothingItemRepository _clothingItemRepo;
  final WeatherRepository _weatherRepo;
  final SuggestionRepository _suggestionRepo;

  GetOutfitSuggestionUseCase(
    this._clothingItemRepo,
    this._weatherRepo,
    this._suggestionRepo,
  );

  Future<Map<String, dynamic>> getWeatherForSuggestion() async {
    final prefs = await SharedPreferences.getInstance();
    final cityModeString = prefs.getString('city_mode') ?? 'auto';
    final cityMode = CityMode.values.byName(cityModeString);

    String cityName = 'Da Nang';
    Map<String, dynamic> weatherData;

    try {
      if (cityMode == CityMode.manual) {
        final lat = prefs.getDouble('manual_city_lat');
        final lon = prefs.getDouble('manual_city_lon');
        final displayName = prefs.getString('manual_city_name');

        if (lat != null && lon != null && displayName != null) {
          logger.i('Get weather by saved coordinates: ($lat, $lon)');
          weatherData = await _weatherRepo.getWeatherByCoords(lat, lon);
          cityName = displayName;
        } else {
          logger.w('Manual location data missing, reverting to default.');
          weatherData = await _weatherRepo.getWeather(cityName);
        }
      } else {
        logger.i('Getting weather by auto-detecting location…');
        // <<< SỬA LỖI GÂY TREO Ở ĐÂY >>>
        // 1. Kiểm tra xem dịch vụ vị trí có được bật không
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          logger.w('Location services are off, reverting to default.');
          // Ném lỗi để khối catch bên dưới xử lý và dùng thành phố mặc định
          throw Exception('Location services are disabled.');
        }

        // 2. Xử lý quyền truy cập
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          logger.w('Location permission are denied, reverting to default.');
          throw Exception('Location permissions are denied.');
        }
        
        // 3. Nếu mọi thứ ổn, mới lấy vị trí
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        weatherData = await _weatherRepo.getWeatherByCoords(
            position.latitude, position.longitude);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        cityName = placemarks.first.locality ?? cityName;
      }
    } catch (e, s) {
      logger.e("Failed to load weather for suggestions, using default.", error: e, stackTrace: s);
      weatherData = await _weatherRepo.getWeather(cityName);
    }

    weatherData['name'] = cityName;
    return weatherData;
  }

  Future<Map<String, dynamic>> execute() async {
    final weatherData = await getWeatherForSuggestion();
    final items = await _clothingItemRepo.getAllItems();

    if (items.isEmpty) {
      return {
        'weather': weatherData,
        'suggestion': 'Please add items to your closet to get suggestions.',
      };
    }

    final suggestionMap = await _suggestionRepo.getOutfitSuggestion(
      weather: weatherData,
      items: items,
      cityName: weatherData['name'],
    );

    final suggestionText =
        "${suggestionMap['suggestion']}\n\n${suggestionMap['reason']}";

    return {
      'weather': weatherData,
      'suggestion': suggestionText,
    };
  }
}