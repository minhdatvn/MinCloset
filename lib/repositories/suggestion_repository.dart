// lib/repositories/suggestion_repository.dart
import 'package:mincloset/services/suggestion_service.dart';

class SuggestionRepository {
  final SuggestionService _suggestionService;

  SuggestionRepository(this._suggestionService);

  // <<< THAY ĐỔI CHỮ KÝ HÀM VÀ THÊM CÁC THAM SỐ MỚI >>>
  Future<Map<String, dynamic>> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required String cityName,
    required String gender,
    required String userStyle,
    required String favoriteColors,
    required String setOutfitsString,
    required String wardrobeString,
  }) {
    return _suggestionService.getOutfitSuggestion(
      weather: weather,
      cityName: cityName,
      gender: gender,
      userStyle: userStyle,
      favoriteColors: favoriteColors,
      setOutfitsString: setOutfitsString,
      wardrobeString: wardrobeString,
    );
  }
}