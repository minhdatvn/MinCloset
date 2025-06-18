// lib/domain/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/use_cases/analyze_item_use_case.dart'; // <<< THÊM
import 'package:mincloset/domain/use_cases/get_outfit_suggestion_use_case.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/services/classification_service.dart'; // <<< THÊM

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
  // UseCase này phụ thuộc vào 3 repository
  final clothingRepo = ref.watch(clothingItemRepositoryProvider);
  final weatherRepo = ref.watch(weatherRepositoryProvider);
  final suggestionRepo = ref.watch(suggestionRepositoryProvider);

  return GetOutfitSuggestionUseCase(clothingRepo, weatherRepo, suggestionRepo);
});

final saveOutfitUseCaseProvider = Provider<SaveOutfitUseCase>((ref) {
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return SaveOutfitUseCase(outfitRepo);
});