// lib/services/suggestion_service.dart

import 'dart.convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SuggestionService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  Future<Either<Failure, Map<String, dynamic>>> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required String cityName,
    required String gender,
    required String userStyle,
    required String favoriteColors,
    required String setOutfitsString,
    required String wardrobeString,
  }) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
    );

    final temp = weather['main']['temp'].toStringAsFixed(0);
    final condition = weather['weather'][0]['description'];

    final prompt = """
    Bạn là 'MinCloset', một trợ lý thời trang AI chuyên nghiệp.

    **Thông tin người dùng:**
    - Giới tính: $gender
    - Phong cách cá nhân: $userStyle
    - Màu sắc yêu thích: $favoriteColors

    **Ngữ cảnh:**
    - Địa điểm: $cityName
    - Thời tiết: $temp°C, $condition

    **Tủ đồ của người dùng bao gồm 2 phần:**

    **1. Các "Set Outfit" (Các món đồ trong một set BẮT BUỘC phải mặc cùng nhau):**
    $setOutfitsString

    **2. Các vật phẩm lẻ (Có thể phối tự do):**
    $wardrobeString

    **YÊU CẦU:**
    1. Dựa vào TẤT CẢ thông tin trên (sở thích, thời tiết, tủ đồ), hãy gợi ý MỘT bộ trang phục phù hợp nhất.
    2. **LUẬT PHỐI ĐỒ:** Nếu bạn chọn MỘT món đồ bất kỳ từ một "Set Outfit", bạn BẮT BUỘC phải chọn TẤT CẢ các món đồ còn lại trong set đó. Bạn có thể kết hợp một "Set Outfit" hoàn chỉnh với các "vật phẩm lẻ" khác.
    3. **KẾT QUẢ TRẢ VỀ:** Hãy trả lời bằng một đối tượng JSON duy nhất, không có bất kỳ văn bản nào khác, với cấu trúc sau:
       {
         "outfit_composition": {
           "topwear": "[Tên món đồ áo]",
           "bottomwear": "[Tên món đồ quần/váy]",
           "outerwear": "[Tên áo khoác (nếu có)]",
           "footwear": "[Tên giày/dép]",
           "accessories": "[Tên phụ kiện (nếu có)]"
         },
         "outfit_name": "[Một cái tên sáng tạo cho bộ đồ]",
         "reason": "[Giải thích ngắn gọn tại sao bộ đồ này phù hợp]"
       }

    **Lưu ý quan trọng:**
    - Với mỗi vị trí trong "outfit_composition", hãy điền tên món đồ CHÍNH XÁC như trong danh sách tủ đồ.
    - Nếu không có món đồ nào phù hợp cho một vị trí (ví dụ: không cần áo khoác), hãy điền `null` cho giá trị đó.
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
      // Trường hợp AI trả về null hoặc text rỗng
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