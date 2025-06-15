// file: lib/services/suggestion_service.dart

import 'package:flutter_dotenv/flutter_dotenv.dart'; // Thêm import
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/utils/logger.dart';

class SuggestionService {
  // Đọc key từ biến môi trường một cách an toàn
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  Future<String> getOutfitSuggestion({
    required Map<String, dynamic> weather,
    required List<ClothingItem> items,
  }) async {
    // 1. Khởi tạo model AI
    // Kiểm tra xem key có được load thành công không
    if (_apiKey == 'API_KEY_NOT_FOUND') {
      return "Lỗi: Không tìm thấy Gemini API Key. Vui lòng kiểm tra lại file .env";
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
    );

    // 2. Chuẩn bị dữ liệu để gửi cho AI
    final temp = weather['main']['temp'].toStringAsFixed(0);
    final condition = weather['weather'][0]['description'];
    final wardrobeString = items.map((item) => '- ${item.name} (${item.category}, màu ${item.color})').join('\n');

    // 3. Soạn câu hỏi (prompt) cho AI
    final prompt = """
      Bạn là 'MinCloset', một trợ lý thời trang AI thân thiện và sành điệu.
      Người dùng đang ở Đà Nẵng, Việt Nam. Thời tiết hiện tại là $temp°C và $condition.

      Đây là tủ đồ của người dùng:
      $wardrobeString

      Dựa vào thời tiết và tủ đồ có sẵn, hãy gợi ý MỘT bộ trang phục hoàn chỉnh và thời trang nhất. Chỉ được sử dụng các món đồ có trong danh sách.
      Hãy trả lời bằng tiếng Việt. Cấu trúc câu trả lời thật rõ ràng: bắt đầu bằng các món đồ được gợi ý, sau đó giải thích ngắn gọn lý do tại sao bộ đồ đó phù hợp.
      Ví dụ:
      **Gợi ý hôm nay:** Áo sơ mi trắng công sở và Quần jean xanh.

      **Lý do:** Thời tiết Đà Nẵng hôm nay khá dễ chịu, bộ trang phục này vừa lịch sự, năng động, phù hợp để đi làm hoặc cà phê cùng bạn bè.
      """;

    // 4. Gửi prompt và nhận kết quả
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? "Xin lỗi, tôi chưa nghĩ ra được gợi ý nào phù hợp.";
    } catch (e, s) { // Thêm 's' để lấy StackTrace
      logger.e(
        'Lỗi khi gọi Gemini API', // Tin nhắn chính
        error: e,     // Đối tượng lỗi
        stackTrace: s, // Stack trace để biết lỗi xảy ra ở đâu
      );
      return "Đã có lỗi xảy ra khi kết nối với AI. Vui lòng thử lại.";
    }
  }
}