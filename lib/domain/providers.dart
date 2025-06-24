// lib/domain/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/helpers/image_helper.dart'; 
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/services/classification_service.dart';
import 'package:mincloset/services/generative_ai_wrapper.dart'; 

final generativeAIWrapperProvider = Provider<IGenerativeAIWrapper>((ref) {
  return GenerativeAIWrapper();
});

// Provider cho Service mới
final classificationServiceProvider = Provider<ClassificationService>((ref) {
  final wrapper = ref.watch(generativeAIWrapperProvider);
  return ClassificationService(aiWrapper: wrapper);
});

// Provider cho UseCase mới
final analyzeItemUseCaseProvider = Provider<AnalyzeItemUseCase>((ref) {
  final service = ref.watch(classificationServiceProvider);
  return AnalyzeItemUseCase(service);
});

final getOutfitSuggestionUseCaseProvider = Provider<GetOutfitSuggestionUseCase>((ref) {
  final clothingRepo = ref.watch(clothingItemRepositoryProvider);
  final weatherRepo = ref.watch(weatherRepositoryProvider);
  final suggestionRepo = ref.watch(suggestionRepositoryProvider);

  return GetOutfitSuggestionUseCase(clothingRepo, weatherRepo, suggestionRepo);
});

final saveOutfitUseCaseProvider = Provider<SaveOutfitUseCase>((ref) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final imageHelper = ref.watch(imageHelperProvider); // <<< Lấy dependency
  return SaveOutfitUseCase(outfitRepo, imageHelper); // <<< Truyền vào
});

final validateItemNameUseCaseProvider = Provider<ValidateItemNameUseCase>((ref) {
  final clothingRepo = ref.watch(clothingItemRepositoryProvider);
  return ValidateItemNameUseCase(clothingRepo);
});

// <<< THÊM PROVIDER MỚI CHO USECASE XÁC THỰC TRƯỜNG BẮT BUỘC >>>
final validateRequiredFieldsUseCaseProvider = Provider<ValidateRequiredFieldsUseCase>((ref) {
  // UseCase này không có phụ thuộc nên chúng ta chỉ cần khởi tạo nó
  return ValidateRequiredFieldsUseCase();
});