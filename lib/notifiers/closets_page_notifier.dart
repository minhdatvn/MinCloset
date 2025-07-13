// lib/notifiers/closets_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:uuid/uuid.dart';

class ClosetsPageState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const ClosetsPageState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  ClosetsPageState copyWith({
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
  }) {
    return ClosetsPageState(
      isLoading: isLoading ?? this.isLoading,
      // Dùng `?.` để cho phép xóa message bằng cách truyền vào null
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

class ClosetsPageNotifier extends StateNotifier<ClosetsPageState> {
  final ClosetRepository _closetRepo;
  final Ref _ref;

  ClosetsPageNotifier(this._closetRepo, this._ref) : super(const ClosetsPageState());

  void clearMessages() {
    state = state.copyWith(successMessage: null, errorMessage: null);
  }

  Future<void> addCloset(
    String name, {
    String? iconName,
    String? colorHex,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Closet name cannot be empty.');
      return;
    }

    state = state.copyWith(isLoading: true);

    final closetsResult = await _closetRepo.getClosets();

    if (!mounted) return;

    await closetsResult.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (closets) async {
        if (closets.length >= 10) {
          state = state.copyWith(isLoading: false, errorMessage: 'Maximum number of closets (10) reached.');
          return;
        }

        final isDuplicate = closets.any((closet) =>
            closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

        if (isDuplicate) {
          state = state.copyWith(isLoading: false, errorMessage: 'A closet with this name already exists.');
          return;
        }

        final newCloset = Closet(
          id: const Uuid().v4(),
          name: trimmedName,
          iconName: iconName,
          colorHex: colorHex,
        );
        final insertResult = await _closetRepo.insertCloset(newCloset);

        if (!mounted) return;

        insertResult.fold(
          (failure) {
            state = state.copyWith(isLoading: false, errorMessage: failure.message);
          },
          (_) async {
            final completedQuests = await _ref
                .read(questRepositoryProvider)
                .updateQuestProgress(QuestEvent.closetCreated);
            
            if (completedQuests.isNotEmpty && mounted) {
              _ref.read(completedQuestProvider.notifier).state = completedQuests.first;
            }
            
            _ref.invalidate(closetsProvider);
            state = state.copyWith(isLoading: false, successMessage: 'Successfully created "$trimmedName" closet.');
          },
        );
      },
    );
  }
  
  Future<void> updateClosetDetails(Closet updatedCloset) async {
    // 1. Kiểm tra tên mới có hợp lệ không
    final trimmedName = updatedCloset.name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Closet name cannot be empty.');
      return;
    }
    if (trimmedName.length > 30) {
      state = state.copyWith(errorMessage: 'Closet name cannot exceed 30 characters.');
      return;
    }

    // 2. Lấy danh sách closets hiện tại để kiểm tra trùng lặp
    final closetsResult = await _closetRepo.getClosets();
    if (!mounted) return;

    await closetsResult.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (closets) async {
        // Kiểm tra xem tên mới có trùng với một closet khác không (loại trừ chính nó)
        final isDuplicate = closets.any((closet) =>
            closet.id != updatedCloset.id &&
            closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

        if (isDuplicate) {
          state = state.copyWith(errorMessage: 'A closet with this name already exists.');
          return;
        }

        // 3. Gọi repository để cập nhật CSDL
        final result = await _closetRepo.updateCloset(updatedCloset);
        if (!mounted) return;

        result.fold(
          (failure) {
            state = state.copyWith(errorMessage: failure.message);
          },
          (_) {
            // 4. Cập nhật thành công, làm mới lại danh sách và báo thành công
            _ref.invalidate(closetsProvider);
            state = state.copyWith(successMessage: 'Closet updated successfully.');
          },
        );
      },
    );
  }

  Future<void> deleteCloset(String closetId) async {
    final clothingItemRepo = _ref.read(clothingItemRepositoryProvider);
    final itemsResult = await clothingItemRepo.getItemsInCloset(closetId);

    if (!mounted) return;

    final itemsInCloset = itemsResult.getOrElse((_) => []);
    if (itemsInCloset.isNotEmpty) {
      state = state.copyWith(errorMessage: 'Closet is not empty. Move or delete items first.');
      return;
    }

    final deleteResult = await _closetRepo.deleteCloset(closetId);

    if (!mounted) return;

    deleteResult.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        _ref.invalidate(closetsProvider);
        // Lấy tên closet để hiển thị thông báo (tùy chọn, có thể bỏ qua để đơn giản)
        state = state.copyWith(successMessage: 'Closet deleted successfully.');
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