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

  Future<Map<String, dynamic>> _getWeatherForSuggestion() async {
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
          logger.i('Lấy thời tiết theo tọa độ đã lưu: ($lat, $lon)');
          weatherData = await _weatherRepo.getWeatherByCoords(lat, lon);
          cityName = displayName;
        } else {
          logger.w('Dữ liệu thành phố thủ công bị thiếu, quay về mặc định.');
          weatherData = await _weatherRepo.getWeather(cityName);
        }
      } else {
        logger.i('Lấy thời tiết theo vị trí tự động...');
        // <<< SỬA LỖI GÂY TREO Ở ĐÂY >>>
        // 1. Kiểm tra xem dịch vụ vị trí có được bật không
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          logger.w('Dịch vụ vị trí đang tắt, quay về mặc định.');
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
          logger.w('Không có quyền truy cập vị trí, quay về mặc định.');
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
      logger.e("Lỗi khi lấy dữ liệu thời tiết cho gợi ý, sử dụng mặc định.", error: e, stackTrace: s);
      weatherData = await _weatherRepo.getWeather(cityName);
    }

    weatherData['name'] = cityName;
    return weatherData;
  }

  Future<Map<String, dynamic>> execute() async {
    final weatherData = await _getWeatherForSuggestion();
    final items = await _clothingItemRepo.getAllItems();

    if (items.isEmpty) {
      return {
        'weather': weatherData,
        'suggestion': 'Hãy thêm đồ vào tủ để nhận gợi ý.',
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