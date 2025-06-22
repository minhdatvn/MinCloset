// lib/services/generative_ai_wrapper.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// 1. Định nghĩa một lớp trừu tượng (interface) cho các hành động chúng ta cần.
//    Lớp này không phải final và có thể mock được.
abstract class IGenerativeAIWrapper {
  Future<String?> generateContent(List<Content> content);
}

// 2. Tạo một lớp triển khai thật sự, lớp này sẽ chứa logic gọi API
class GenerativeAIWrapper implements IGenerativeAIWrapper {
  final GenerativeModel _model;

  GenerativeAIWrapper()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND',
        );

  @override
  Future<String?> generateContent(List<Content> content) async {
    final response = await _model.generateContent(content);
    return response.text;
  }
}