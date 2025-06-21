// lib/notifiers/closet_detail_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/closet_detail_state.dart';
import 'package:mincloset/utils/debouncer.dart'; // <<< THÊM IMPORT MỚI

class ClosetDetailNotifier extends StateNotifier<ClosetDetailState> {
  final ClothingItemRepository _repo;
  final String _closetId;
  // <<< THAY THẾ Timer bằng Debouncer >>>
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  ClosetDetailNotifier(this._repo, this._closetId) : super(const ClosetDetailState()) {
    searchItems('');
  }

  Future<void> searchItems(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);

    // <<< SỬ DỤNG DEBOUNCER, CODE NGẮN GỌN VÀ DỄ ĐỌC HƠN >>>
    _debouncer.run(() async {
      try {
        final items = await _repo.searchItemsInCloset(_closetId, state.searchQuery);
        if (mounted) {
          state = state.copyWith(items: items, isLoading: false);
        }
      } catch (e) {
        if (mounted) {
          state = state.copyWith(errorMessage: "Lỗi tìm kiếm", isLoading: false);
        }
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose(); // Hủy timer khi notifier bị hủy
    super.dispose();
  }
}

// Provider không thay đổi
final closetDetailProvider = StateNotifierProvider.autoDispose
    .family<ClosetDetailNotifier, ClosetDetailState, String>((ref, closetId) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ClosetDetailNotifier(repo, closetId);
});