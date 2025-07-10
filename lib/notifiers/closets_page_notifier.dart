// lib/notifiers/closets_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:uuid/uuid.dart';

// State của trang này rất đơn giản, chỉ cần biết loading hay có lỗi không
class ClosetsPageState {
  final bool isLoading;
  final String? error;
  const ClosetsPageState({this.isLoading = false, this.error});

  ClosetsPageState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ClosetsPageState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ClosetsPageNotifier extends StateNotifier<ClosetsPageState> {
  final ClosetRepository _closetRepo;
  final Ref _ref;

  ClosetsPageNotifier(this._closetRepo, this._ref) : super(const ClosetsPageState());

  Future<String?> addCloset(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Closet name cannot be empty.';
    }
    if (trimmedName.length > 30) {
      return 'Closet name cannot exceed 30 characters.';
    }

    state = state.copyWith(isLoading: true);

    final closetsResult = await _closetRepo.getClosets();

    if (!mounted) return null;

    return await closetsResult.fold(
      (failure) {
        state = state.copyWith(isLoading: false);
        return failure.message;
      },
      (closets) async {
        if (closets.length >= 10) {
          state = state.copyWith(isLoading: false);
          return 'Maximum number of closets (10) reached.';
        }

        final isDuplicate = closets.any((closet) =>
            closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

        if (isDuplicate) {
          state = state.copyWith(isLoading: false);
          return 'A closet with this name already exists.';
        }

        final newCloset = Closet(id: const Uuid().v4(), name: trimmedName);
        final insertResult = await _closetRepo.insertCloset(newCloset);

        if (!mounted) return null;

        state = state.copyWith(isLoading: false);

        return insertResult.fold(
          (failure) => failure.message,
          (_) async { // THAY ĐỔI 1: Chuyển thành hàm async để dùng await
            
            // THAY ĐỔI 2: Phát đi sự kiện closetCreated và kiểm tra kết quả
            final completedQuests = await _ref
                .read(questRepositoryProvider)
                .updateQuestProgress(QuestEvent.closetCreated);
            
            if (completedQuests.isNotEmpty && mounted) {
              _ref.read(completedQuestProvider.notifier).state = completedQuests.first;
            }

            // Các dòng code cũ giữ nguyên
            _ref.invalidate(closetsProvider); 
            return null;
          },
        );
      },
    );
  }
  
  Future<String?> updateCloset(Closet closetToUpdate, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return 'Closet name cannot be empty.';
    }
    if (trimmedName.length > 30) {
      return 'Closet name cannot exceed 30 characters.';
    }

    final closetsResult = await _closetRepo.getClosets();
    if (!mounted) return null;

    return await closetsResult.fold((failure) {
      return failure.message;
    }, (closets) async {
      final isDuplicate = closets.any((closet) =>
          closet.id != closetToUpdate.id &&
          closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

      if (isDuplicate) {
        return 'A closet with this name already exists.';
      }

      final result = await _closetRepo
          .updateCloset(closetToUpdate.copyWith(name: trimmedName));

      if (!mounted) return null;

      return result.fold(
        (failure) => failure.message,
        (_) {
          _ref.invalidate(closetsProvider);
          return null;
        },
      );
    });
  }

  Future<String?> deleteCloset(String closetId) async {
    final clothingItemRepo = _ref.read(clothingItemRepositoryProvider);
    final itemsResult = await clothingItemRepo.getItemsInCloset(closetId);

    if (!mounted) return null;

    final itemsInCloset = itemsResult.getOrElse((_) => []);
    if (itemsInCloset.isNotEmpty) {
      return 'Closet is not empty. Move or delete items first.';
    }

    final deleteResult = await _closetRepo.deleteCloset(closetId);

    if (!mounted) return null;

    return deleteResult.fold(
      (failure) => failure.message,
      (_) {
        _ref.invalidate(closetsProvider);
        return null;
      },
    );
  }
}

// <<< THAY ĐỔI QUAN TRỌNG NHẤT: XÓA .autoDispose >>>
final closetsPageProvider =
    StateNotifierProvider<ClosetsPageNotifier, ClosetsPageState>((ref) {
  final repo = ref.watch(closetRepositoryProvider);
  return ClosetsPageNotifier(repo, ref);
});