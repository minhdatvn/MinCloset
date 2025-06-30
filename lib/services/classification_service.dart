// lib/services/classification_service.dart

import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/constants/prompt_strings.dart'; // <<< THÊM IMPORT
import 'package:mincloset/services/generative_ai_wrapper.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassificationService {
  final IGenerativeAIWrapper _aiWrapper;

  ClassificationService({required IGenerativeAIWrapper aiWrapper}) : _aiWrapper = aiWrapper;

  Future<Map<String, dynamic>> classifyImage(XFile image) async {
    final imageBytes = await image.readAsBytes();
    final dataPart = DataPart('image/jpeg', imageBytes);

    // --- BẮT ĐẦU THAY ĐỔI LOGIC ---
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    final strings = PromptStrings.localized[langCode]!; // Lấy bộ chuỗi dịch

    final prompt = TextPart("""
      ${strings['classification_role']}
      ${strings['classification_name_instruction']}
      ${strings['classification_category_instruction']} ${jsonEncode(AppOptions.categories)}
      ${strings['classification_colors_instruction']} ${jsonEncode(AppOptions.colors.keys.toList())}
      ${strings['classification_material_instruction']} ${jsonEncode(AppOptions.materials.map((e) => e.name).toList())}
      ${strings['classification_pattern_instruction']} ${jsonEncode(AppOptions.patterns.map((e) => e.name).toList())}
      """);
    // --- KẾT THÚC THAY ĐỔI LOGIC ---
      
    try {
      final responseText = await _aiWrapper.generateContent([
        Content.multi([prompt, dataPart])
      ]);
      
      if (responseText != null) {
        final cleanJsonString = responseText
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