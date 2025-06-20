// lib/domain/use_cases/get_outfit_suggestion_use_case.dart

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/utils/logger.dart';

class GetOutfitSuggestionUseCase {
  final ClothingItemRepository _clothingItemRepo;
  final WeatherRepository _weatherRepo;
  final SuggestionRepository _suggestionRepo;

  GetOutfitSuggestionUseCase(
    this._clothingItemRepo,
    this._weatherRepo,
    this._suggestionRepo,
  );

  Future<String> _getCityForWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final cityMode = prefs.getString('city_mode') ?? 'auto';

    if (cityMode == 'manual') {
      return prefs.getString('manual_city') ?? 'Da Nang';
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Da Nang';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Da Nang';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      return placemarks.first.locality ?? 'Da Nang';
    } catch (e, s) {
      logger.e(
        "Lỗi khi lấy vị trí tự động",
        error: e,
        stackTrace: s,
      );
      return 'Da Nang';
    }
  }

  // <<< THAY ĐỔI: Hàm này trả về một Map chứa cả weather và suggestion text >>>
  Future<Map<String, dynamic>> execute() async {
    final city = await _getCityForWeather();

    final results = await Future.wait([
      _weatherRepo.getWeather(city),
      _clothingItemRepo.getAllItems(),
    ]);

    final weatherData = results[0] as Map<String, dynamic>;
    final items = results[1] as List<ClothingItem>;

    if (items.isEmpty) {
      return {
        'weather': weatherData,
        'suggestion': 'Hãy thêm đồ vào tủ để nhận gợi ý.',
      };
    }

    // <<< THAY ĐỔI: Xử lý kết quả JSON từ Repository >>>
    final suggestionMap = await _suggestionRepo.getOutfitSuggestion(
      weather: weatherData,
      items: items,
      cityName: city,
    );

    // Ghép kết quả lại thành một chuỗi hoàn chỉnh để hiển thị
    final suggestionText = "${suggestionMap['suggestion']}\n\n${suggestionMap['reason']}";

    return {
      'weather': weatherData,
      'suggestion': suggestionText,
    };
  }
}