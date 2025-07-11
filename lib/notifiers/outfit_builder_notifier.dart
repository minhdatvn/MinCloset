// lib/notifiers/outfit_builder_notifier.dart

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/outfits_hub_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/states/outfit_builder_state.dart';

class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final ClothingItemRepository _clothingItemRepo;
  final SaveOutfitUseCase _saveOutfitUseCase;
  final OutfitRepository _outfitRepo;
  final Ref _ref;

  OutfitBuilderNotifier(
    this._clothingItemRepo,
    this._saveOutfitUseCase,
    this._outfitRepo,
    this._ref,
  ) : super(const OutfitBuilderState()) {
    loadAvailableItems();
  }

  Future<void> loadAvailableItems() async {
    state = state.copyWith(isLoading: true, saveSuccess: false, errorMessage: null);
    final itemsEither = await _clothingItemRepo.getAllItems();
    
    if (!mounted) return;

    itemsEither.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: "Could not load items for sticker drawer.",
          isLoading: false,
        );
      },
      (items) {
        state = state.copyWith(
          allItems: items,
          isLoading: false,
        );
      },
    );
  }

  // <<< THAY ĐỔI 1: Chuyển lại thành Future<void> và quản lý state >>>
  Future<void> saveOutfit({
    required String name,
    required bool isFixed,
    required Map<String, ClothingItem> itemsOnCanvas,
    required Uint8List capturedImage,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null, saveSuccess: false);

    if (itemsOnCanvas.isEmpty) {
      state = state.copyWith(errorMessage: 'Please add at least one item to save the outfit!', isSaving: false);
      return;
    }

    if (isFixed) {
      final Either<Failure, String?> validationResult = await _validateFixedOutfit(itemsOnCanvas);
      
      if (!mounted) return;

      final hasError = validationResult.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message, isSaving: false);
          return true;
        },
        (errorMessage) {
          if (errorMessage != null) {
            state = state.copyWith(errorMessage: errorMessage, isSaving: false);
            return true;
          }
          return false;
        },
      );

      if (hasError) {
        return;
      }
    }

    final saveResult = await _saveOutfitUseCase.execute(
      name: name,
      isFixed: isFixed,
      itemsOnCanvas: itemsOnCanvas,
      capturedImage: capturedImage,
    );

    if (!mounted) return;
    
    saveResult.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message, isSaving: false);
      },
      (_) async {
        final questRepo = _ref.read(questRepositoryProvider);
        final achievementRepo = _ref.read(achievementRepositoryProvider);

        // 1. Lấy kết quả từ việc cập nhật quest
        final completedQuests = await questRepo.updateQuestProgress(QuestEvent.outfitCreated);

        // 2. Nếu có quest hoàn thành, gửi tín hiệu cho mascot thông qua provider
        if (completedQuests.isNotEmpty && mounted) {
            _ref.read(completedQuestProvider.notifier).state = completedQuests.first;
        }
        
        final allQuests = questRepo.getCurrentQuests();
        final unlockedAchievement = await achievementRepo.checkAndUnlockAchievements(allQuests);

        _ref.invalidate(outfitsHubProvider);
        
        // <<< THAY ĐỔI 2: Đặt cờ saveSuccess thành true >>>
        // Giao diện sẽ lắng nghe sự thay đổi này để tự điều hướng
        state = state.copyWith(
          saveSuccess: true, 
          isSaving: false,
          newlyUnlockedAchievement: unlockedAchievement,
        );
      }
    );
  }

  Future<Either<Failure, String?>> _validateFixedOutfit(Map<String, ClothingItem> itemsOnCanvas) async {
    final newItemIds = itemsOnCanvas.values.map((item) => item.id).toSet();
    final existingFixedOutfitsEither = await _outfitRepo.getFixedOutfits();

    return existingFixedOutfitsEither.fold(
      (failure) => Left(failure), 
      (existingFixedOutfits) async {
        for (final fixedOutfit in existingFixedOutfits) {
          final existingItemIds = fixedOutfit.itemIds.split(',').toSet();
          final intersection = newItemIds.intersection(existingItemIds);

          if (intersection.isNotEmpty) {
            final conflictingItemId = intersection.first;
            final conflictingItemEither = await _clothingItemRepo.getItemById(conflictingItemId);
            
            return conflictingItemEither.fold(
              (failure) => Left(failure), 
              (conflictingItem) => Right("Error: '${conflictingItem?.name ?? 'An item'}' already belongs to another fixed outfit.")
            );
          }
        }
        return const Right(null); 
      },
    );
  }
}

final outfitBuilderProvider =
    StateNotifierProvider.autoDispose<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  final clothingItemRepo = ref.watch(clothingItemRepositoryProvider);
  final saveOutfitUseCase = ref.watch(saveOutfitUseCaseProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return OutfitBuilderNotifier(clothingItemRepo, saveOutfitUseCase, outfitRepo, ref); 
});