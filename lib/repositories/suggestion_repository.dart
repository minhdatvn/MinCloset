// lib/repositories/suggestion_repository.dart
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/services/suggestion_service.dart';

class SuggestionRepository {
  final SuggestionService _suggestionService;

  SuggestionRepository(this._suggestionService);

  // <<< THÊM `required String cityName` VÀO ĐÂY
  Future<String> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required List<ClothingItem> items,
    required String cityName,
  }) {
    // Và truyền nó xuống service
    return _suggestionService.getOutfitSuggestion(weather: weather, items: items, cityName: cityName);
  }
}