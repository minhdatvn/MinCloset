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

    // Xử lý logic cho chế độ "auto"
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
    } catch (e, s) { // <<< THAY ĐỔI: Bắt cả StackTrace (s)
      // <<< THAY ĐỔI: Dùng logger.e thay cho print()
      logger.e(
        "Lỗi khi lấy vị trí tự động",
        error: e,
        stackTrace: s,
      );
      // Nếu có lỗi, quay về thành phố mặc định
      return 'Da Nang';
    }
  }

  Future<Map<String, dynamic>> execute() async {
    // 1. Lấy tên thành phố (đã có từ bước trước)
    final city = await _getCityForWeather();

    // 2. Gọi API và CSDL song song
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

    // <<< THAY ĐỔI Ở ĐÂY: Truyền `city` vào hàm getOutfitSuggestion
    final suggestionText = await _suggestionRepo.getOutfitSuggestion(
      weather: weatherData,
      items: items,
      cityName: city, // Truyền tên thành phố đã xác định vào
    );

    return {
      'weather': weatherData,
      'suggestion': suggestionText,
    };
  }
}