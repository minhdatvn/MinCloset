// lib/domain/use_cases/get_outfit_suggestion_use_case.dart

import 'package:mincloset/models/clothing_item.dart'; // <<< THÊM DÒNG IMPORT NÀY
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';

// Lớp Use Case chỉ có một nhiệm vụ duy nhất
class GetOutfitSuggestionUseCase {
  final ClothingItemRepository _clothingItemRepo;
  final WeatherRepository _weatherRepo;
  final SuggestionRepository _suggestionRepo;

  // Nhận các repository cần thiết qua constructor
  GetOutfitSuggestionUseCase(
    this._clothingItemRepo,
    this._weatherRepo,
    this._suggestionRepo,
  );

  // Phương thức `execute` chứa toàn bộ logic nghiệp vụ
  Future<Map<String, dynamic>> execute() async {
    // Gọi song song để tối ưu thời gian
    final results = await Future.wait([
      _weatherRepo.getWeather('Da Nang'),
      _clothingItemRepo.getAllItems(),
    ]);

    final weatherData = results[0] as Map<String, dynamic>;
    // `getAllItems` từ repository đã trả về đúng kiểu List<ClothingItem>
    final items = results[1] as List<ClothingItem>;

    if (items.isEmpty) {
      return {
        'weather': weatherData,
        'suggestion': 'Hãy thêm đồ vào tủ để nhận gợi ý.',
      };
    }

    final suggestionText = await _suggestionRepo.getOutfitSuggestion(
      weather: weatherData,
      items: items, 
    );

    return {
      'weather': weatherData,
      'suggestion': suggestionText,
    };
  }
}