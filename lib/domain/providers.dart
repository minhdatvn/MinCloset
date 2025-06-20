// lib/domain/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart';
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart'; // <<< THÊM IMPORT MỚI
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/services/classification_service.dart';

// Provider cho Service mới
final classificationServiceProvider = Provider<ClassificationService>((ref) {
  return ClassificationService();
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
  return SaveOutfitUseCase(outfitRepo);
});

// <<< THÊM PROVIDER CHO USECASE XÁC THỰC TÊN >>>
final validateItemNameUseCaseProvider = Provider<ValidateItemNameUseCase>((ref) {
  final clothingRepo = ref.watch(clothingItemRepositoryProvider);
  return ValidateItemNameUseCase(clothingRepo);
});