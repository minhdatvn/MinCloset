// lib/domain/use_cases/analyze_item_use_case.dart

import 'package:image_picker/image_picker.dart';
import 'package:mincloset/domain/core/type_defs.dart'; // Thêm import
import 'package:mincloset/services/classification_service.dart';

class AnalyzeItemUseCase {
  final ClassificationService _service;

  AnalyzeItemUseCase(this._service);

  // THAY ĐỔI: Cập nhật kiểu trả về
  FutureEither<Map<String, dynamic>> execute(XFile image) {
    return _service.classifyImage(image);
  }
}