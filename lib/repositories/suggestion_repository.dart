// lib/repositories/suggestion_repository.dart
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/services/suggestion_service.dart';

class SuggestionRepository {
  final SuggestionService _suggestionService;

  SuggestionRepository(this._suggestionService);

  FutureEither<Map<String, dynamic>> getOutfitSuggestion({
    required Map<String, dynamic>? weather,
    required String cityName,
    required String gender,
    required String userStyle,
    required String favoriteColors,
    required String setOutfitsString,
    required String closetItemsString,
    String? purpose, // <<< THÊM VÀO
  }) {
    return _suggestionService.getOutfitSuggestion(
      weather: weather,
      cityName: cityName,
      gender: gender,
      userStyle: userStyle,
      favoriteColors: favoriteColors,
      setOutfitsString: setOutfitsString,
      closetItemsString: closetItemsString,
      purpose: purpose, // <<< THÊM VÀO
    );
  }
}