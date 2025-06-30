// lib/services/classification_service.dart

import 'dart:convert';
import 'dart:io'; // Thêm import này

import 'package:fpdart/fpdart.dart'; // Thêm import này
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/constants/app_options.dart';
import 'package:mincloset/constants/prompt_strings.dart';
import 'package:mincloset/domain/core/type_defs.dart'; // Thêm import này
import 'package:mincloset/domain/failures/failures.dart'; // Thêm import này
import 'package:mincloset/services/generative_ai_wrapper.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassificationService {
  final IGenerativeAIWrapper _aiWrapper;

  ClassificationService({required IGenerativeAIWrapper aiWrapper}) : _aiWrapper = aiWrapper;

  // THAY ĐỔI 1: Cập nhật kiểu trả về của hàm
  FutureEither<Map<String, dynamic>> classifyImage(XFile image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final dataPart = DataPart('image/jpeg', imageBytes);

      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('language_code') ?? 'en';
      final strings = PromptStrings.localized[langCode]!;
      
      final prompt = TextPart("""
        ${strings['classification_role']}
        ${strings['classification_name_instruction']}
        ${strings['classification_category_instruction']} ${jsonEncode(AppOptions.categories)}
        ${strings['classification_colors_instruction']} ${jsonEncode(AppOptions.colors.keys.toList())}
        ${strings['classification_material_instruction']} ${jsonEncode(AppOptions.materials.map((e) => e.name).toList())}
        ${strings['classification_pattern_instruction']} ${jsonEncode(AppOptions.patterns.map((e) => e.name).toList())}
        """);
        
      final responseText = await _aiWrapper.generateContent([
        Content.multi([prompt, dataPart])
      ]);
      
      if (responseText != null && responseText.isNotEmpty) {
        final cleanJsonString = responseText
            .replaceAll(RegExp(r'```json\n?'), '')
            .replaceAll(RegExp(r'```'), '')
            .trim();
            
        logger.i("Phản hồi từ AI (đã làm sạch): $cleanJsonString");
        // THAY ĐỔI 2: Trả về Right khi thành công
        return Right(json.decode(cleanJsonString) as Map<String, dynamic>);
      }
      // THAY ĐỔI 3: Trả về Left khi AI không có phản hồi
      return const Left(ServerFailure('AI did not return a response. It might be due to safety settings or network issues.'));

    // THAY ĐỔI 4: Bắt các loại lỗi cụ thể và trả về Left
    } on SocketException {
      return const Left(NetworkFailure('No internet connection. Please check your network and try again.'));
    } on Exception catch (e, s) {
      logger.e(
        'Lỗi khi gọi Classification API',
        error: e,
        stackTrace: s,
      );
      return Left(ServerFailure('An error occurred while analyzing the image: $e'));
    }
  }
}