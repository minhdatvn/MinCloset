// lib/services/generative_ai_wrapper.dart

import 'package:google_generative_ai/google_generative_ai.dart';
// 1. Thêm import cho secure_storage_service
import 'package:mincloset/services/secure_storage_service.dart';

abstract class IGenerativeAIWrapper {
  Future<String?> generateContent(List<Content> content);
}

class GenerativeAIWrapper implements IGenerativeAIWrapper {
  // 2. Thay đổi constructor để nhận SecureStorageService
  final SecureStorageService _secureStorage;
  GenerativeAIWrapper(this._secureStorage);

  // 3. Xóa việc khởi tạo _model ở đây

  @override
  Future<String?> generateContent(List<Content> content) async {
    // 4. Lấy API key và khởi tạo model ngay bên trong hàm
    final apiKey = await _secureStorage.read(SecureStorageKeys.geminiApiKey);
    if (apiKey == null || apiKey.isEmpty) {
      // Nếu không có key, không thể tiếp tục
      throw Exception('Gemini API key not found in secure storage.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: apiKey,
    );
    
    final response = await model.generateContent(content);
    return response.text;
  }
}