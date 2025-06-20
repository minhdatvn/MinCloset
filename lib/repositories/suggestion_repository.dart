// lib/repositories/suggestion_repository.dart
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/services/suggestion_service.dart';

class SuggestionRepository {
  final SuggestionService _suggestionService;

  SuggestionRepository(this._suggestionService);

  // <<< THAY ĐỔI KIỂU DỮ LIỆU TRẢ VỀ Ở ĐÂY >>>
  // Sửa từ Future<String> thành Future<Map<String, String>>
  Future<Map<String, String>> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required List<ClothingItem> items,
    required String cityName,
  }) {
    // Giờ đây kiểu trả về đã đồng bộ với service
    return _suggestionService.getOutfitSuggestion(
      weather: weather,
      items: items,
      cityName: cityName,
    );
  }
}