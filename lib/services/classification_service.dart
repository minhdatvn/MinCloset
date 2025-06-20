// lib/services/classification_service.dart

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/utils/logger.dart';

class ClassificationService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  Future<Map<String, dynamic>> classifyImage(XFile image) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
    );

    final imageBytes = await image.readAsBytes();
    final dataPart = DataPart('image/jpeg', imageBytes);

    final categoriesJson = jsonEncode(AppOptions.categories);
    final colorsJson = jsonEncode(AppOptions.colors.keys.toList());
    final materialsJson = jsonEncode(AppOptions.materials.map((e) => e.name).toList());
    final patternsJson = jsonEncode(AppOptions.patterns.map((e) => e.name).toList());

    // <<< SỬA ĐỔI PROMPT Ở ĐÂY >>>
    final prompt = TextPart("""
      Bạn là một chuyên gia phân loại thời trang. Dựa vào hình ảnh được cung cấp, hãy phân tích và trả về một đối tượng JSON duy nhất có các key sau: "name", "category", "colors", "material", "pattern".

      1. "category": Phân tích theo 2 bước. Đầu tiên, xác định danh mục chính (Tầng 1). Sau đó, tìm danh mục con phù hợp nhất (Tầng 2) trong danh sách tương ứng được cung cấp. Trả về kết quả dưới dạng chuỗi "Danh mục chính > Danh mục con". Nếu không tìm thấy danh mục con phù hợp, hãy dùng "Khác" làm danh mục con. Nếu không xác định được cả danh mục chính, trả về "Khác > Khác". Cấu trúc danh mục: $categoriesJson

      2. "colors": Trả về một MẢNG CHỨA CÁC CHUỖI TÊN MÀU có trong ảnh. Cố gắng xác định tất cả các màu có thể từ danh sách sau: $colorsJson

      3. "material": CHỈ CHỌN MỘT chất liệu gần đúng nhất từ danh sách sau: $materialsJson. Nếu không chắc chắn, trả về "Khác".

      4. "pattern": CHỈ CHỌN MỘT họa tiết gần đúng nhất từ danh sách sau: $patternsJson. Nếu không chắc chắn, trả về "Khác".

      5. "name": Dựa vào các thuộc tính đã phân tích (đặc biệt là danh mục và màu sắc chính), hãy đặt một cái tên ngắn gọn, mô tả cho vật phẩm bằng tiếng Việt (ví dụ: 'Áo thun cotton trắng', 'Giày sneaker da đen'). Tên không quá 30 ký tự.
      """);
      
    try {
      final response = await model.generateContent([
        Content.multi([prompt, dataPart])
      ]);
      
      if (response.text != null) {
        final cleanJsonString = response.text!
            .replaceAll(RegExp(r'```json\n?'), '')
            .replaceAll(RegExp(r'```'), '')
            .trim();
            
        logger.i("Phản hồi từ AI (đã làm sạch): $cleanJsonString");
        return json.decode(cleanJsonString) as Map<String, dynamic>;
      }
      throw Exception('AI response is null');

    } catch (e, s) {
      logger.e(
        'Lỗi khi gọi Classification API',
        error: e,
        stackTrace: s,
      );
      return {};
    }
  }
}