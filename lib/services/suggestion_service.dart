// lib/services/suggestion_service.dart

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mincloset/constants/prompt_strings.dart'; // <<< THÊM DÒNG NÀY
import 'package:mincloset/domain/core/type_defs.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  FutureEither<Map<String, dynamic>> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required String cityName,
    required String gender,
    required String userStyle,
    required String favoriteColors,
    required String setOutfitsString,
    required String wardrobeString,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
    );

    final temp = weather['main']['temp'].toStringAsFixed(0);
    final condition = weather['weather'][0]['description'];

    // <<< LOGIC MỚI: XÂY DỰNG PROMPT ĐỘNG >>>
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    final strings = PromptStrings.localized[langCode]!; // Lấy bộ chuỗi dịch tương ứng

    final prompt = """
    ${strings['assistant_role']}

    ${strings['user_info_title']}
    ${strings['gender_label']} $gender
    ${strings['style_label']} $userStyle
    ${strings['colors_label']} $favoriteColors

    ${strings['context_title']}
    ${strings['location_label']} $cityName
    ${strings['weather_label']} $temp°C, $condition

    ${strings['wardrobe_title']}
    ${strings['set_outfits_title']}
    $setOutfitsString
    ${strings['individual_items_title']}
    $wardrobeString

    ${strings['request_title']}
    ${strings['request_1']}
    ${strings['request_2']}
    ${strings['request_3']}
       {
         "outfit_composition": {
           ${strings['composition_topwear']},
           ${strings['composition_bottomwear']},
           ${strings['composition_outerwear']},
           ${strings['composition_footwear']},
           ${strings['composition_accessories']}
         },
         ${strings['outfit_name_desc']},
         ${strings['reason_desc']}
       }

    ${strings['important_notes_title']}
    ${strings['note_1']}
    ${strings['note_2']}
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        final cleanJsonString = response.text!
            .replaceAll(RegExp(r'```json\n?'), '')
            .replaceAll(RegExp(r'```'), '')
            .trim();
        
        logger.i("Phản hồi gợi ý từ AI (đã làm sạch): $cleanJsonString");
        final decodedJson = json.decode(cleanJsonString) as Map<String, dynamic>;
        
        return Right(decodedJson);
      }
      return const Left(ServerFailure('AI response was empty.'));

    } catch (e, s) {
      logger.e(
        'Lỗi khi gọi Gemini API cho gợi ý',
        error: e,
        stackTrace: s,
      );
      Sentry.captureException(e, stackTrace: s);
      return Left(ServerFailure('Could not connect to the AI service: $e'));
    }
  }
}