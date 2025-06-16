// lib/notifiers/closet_detail_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/closet_detail_state.dart';

class ClosetDetailNotifier extends StateNotifier<ClosetDetailState> {
  final ClothingItemRepository _repo;
  final String _closetId;
  Timer? _debounce; // Biến dùng cho việc debounce

  ClosetDetailNotifier(this._repo, this._closetId) : super(const ClosetDetailState()) {
    // Tải toàn bộ item ban đầu
    searchItems('');
  }

  Future<void> searchItems(String query) async {
    // Cập nhật query ngay lập tức, nhưng trì hoãn việc gọi CSDL
    state = state.copyWith(searchQuery: query, isLoading: true);

    // Debounce logic: Hủy timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Tạo một timer mới, chỉ thực hiện tìm kiếm sau 500ms người dùng ngừng gõ
    _debounce = Timer(const Duration(milliseconds: 500), () async {
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
    _debounce?.cancel(); // Hủy timer khi notifier bị hủy
    super.dispose();
  }
}

final closetDetailProvider = StateNotifierProvider.autoDispose
    .family<ClosetDetailNotifier, ClosetDetailState, String>((ref, closetId) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ClosetDetailNotifier(repo, closetId);
});