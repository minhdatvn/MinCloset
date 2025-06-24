// lib/services/suggestion_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/utils/logger.dart';

class SuggestionService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  // <<< THAY ĐỔI: HÀM NÀY GIỜ TRẢ VỀ Map<String, String> >>>
  Future<Map<String, String>> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required List<ClothingItem> items,
    required String cityName,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
    );

    final temp = weather['main']['temp'].toStringAsFixed(0);
    final condition = weather['weather'][0]['description'];
    final wardrobeString = items.map((item) => '- ${item.name} (${item.category}, màu ${item.color})').join('\n');

    // <<< THAY ĐỔI: Cập nhật prompt để yêu cầu trả về JSON >>>
    final prompt = """
      Bạn là 'MinCloset', một trợ lý thời trang AI sành điệu.
      Người dùng đang ở $cityName. Thời tiết hiện tại là $temp°C và $condition.
      Tủ đồ của người dùng:
      $wardrobeString

      Dựa vào thời tiết và tủ đồ, hãy gợi ý MỘT bộ trang phục hoàn chỉnh và thời trang nhất. Chỉ được sử dụng các món đồ có trong danh sách.
      Hãy trả lời bằng một đối tượng JSON duy nhất có 2 keys:
      1. "suggestion": Một chuỗi liệt kê các món đồ được chọn. Ví dụ: "Áo thun trắng + Quần jeans xanh + Giày sneaker".
      2. "reason": Một chuỗi giải thích ngắn gọn (1-2 câu) tại sao bộ đồ đó phù hợp.

      Chỉ trả về đối tượng JSON, không có bất kỳ văn bản nào khác.
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

        return {
          'suggestion': decodedJson['suggestion'] as String? ?? '',
          'reason': decodedJson['reason'] as String? ?? ''
        };
      }
      throw Exception('AI response is null or invalid.');

    } catch (e, s) {
      logger.e(
        'Lỗi khi gọi Gemini API cho gợi ý',
        error: e,
        stackTrace: s,
      );
      // Trả về map rỗng để báo hiệu lỗi
      return {
        'suggestion': 'Đã có lỗi xảy ra khi kết nối với AI.',
        'reason': 'Vui lòng thử lại.'
      };
    }
  }
}