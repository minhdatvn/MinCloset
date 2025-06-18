// lib/domain/use_cases/analyze_item_use_case.dart

import 'package:image_picker/image_picker.dart';
import 'package:mincloset/services/classification_service.dart';

class AnalyzeItemUseCase {
  final ClassificationService _service;

  AnalyzeItemUseCase(this._service);

  Future<Map<String, dynamic>> execute(XFile image) {
    return _service.classifyImage(image);
  }
}