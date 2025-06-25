import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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

    Map<String, dynamic> weatherData;
    String displayName = 'Da Nang'; // Tên hiển thị mặc định

    try {
      if (cityMode == CityMode.manual) {
        final lat = prefs.getDouble('manual_city_lat');
        final lon = prefs.getDouble('manual_city_lon');
        final manualCityName = prefs.getString('manual_city_name');

        if (lat != null && lon != null && manualCityName != null) {
          logger.i('Get weather by saved coordinates: ($lat, $lon)');
          weatherData = await _weatherRepo.getWeatherByCoords(lat, lon);
          displayName = manualCityName;
        } else {
          logger.w('Manual location data missing, reverting to default.');
          weatherData = await _weatherRepo.getWeather(displayName);
        }
      } else { // Chế độ tự động
        logger.i('Getting weather by auto-detecting location…');
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are denied.');
        }
        
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        weatherData = await _weatherRepo.getWeatherByCoords(
            position.latitude, position.longitude);
            
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        
        // Ưu tiên lấy administrativeArea (tên tỉnh/thành phố), nếu không có mới lấy locality (quận/huyện)
        displayName = placemarks.first.administrativeArea ?? placemarks.first.locality ?? displayName;
      }
    } catch (e, s) {
      logger.e("Failed to load weather for suggestions, using default.", error: e, stackTrace: s);
      // Báo cáo lỗi không lấy được thời tiết lên Sentry
      await Sentry.captureException(e, stackTrace: s);
      // Nếu có bất kỳ lỗi nào ở trên, chuyển sang dùng thành phố mặc định
      weatherData = await _weatherRepo.getWeather(displayName);
    }
    
    // Đảm bảo gán tên hiển thị trước khi trả về
    weatherData['name'] = displayName;
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