// lib/notifiers/closet_detail_notifier.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/closet_detail_state.dart';
import 'package:mincloset/utils/logger.dart';

const _pageSize = 18;

class ClosetDetailNotifier extends StateNotifier<ClosetDetailState> {
  final ClothingItemRepository _repo;
  final String _closetId;
  Timer? _debounce;
  bool _isDisposed = false;

  ClosetDetailNotifier(this._repo, this._closetId) : super(const ClosetDetailState()) {
    fetchInitialItems();
  }

  Future<void> _fetchPage(int page) async {
    try {
      final newItems = await _repo.searchItemsInCloset(
        _closetId,
        state.searchQuery,
        limit: _pageSize,
        offset: page * _pageSize,
      );

      if (_isDisposed) return;

      final currentItems = page == 0 ? <ClothingItem>[] : state.items;
      
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        items: [...currentItems, ...newItems],
        hasMore: newItems.length == _pageSize,
      );
    } catch (e, s) {
      if (_isDisposed) return;
      logger.e("Failed to load items in closet", error: e, stackTrace: s);
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: "Failed to load items.",
      );
    }
  }

  Future<void> fetchInitialItems() async {
    state = state.copyWith(isLoading: true, items: [], hasMore: true, clearError: true);
    await _fetchPage(0);
  }

  Future<void> fetchMoreItems() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = (state.items.length / _pageSize).floor();
    await _fetchPage(nextPage);
  }
  
  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(searchQuery: query);
      fetchInitialItems(); // Tải lại từ đầu với query mới
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}

final closetDetailProvider = StateNotifierProvider.autoDispose
    .family<ClosetDetailNotifier, ClosetDetailState, String>((ref, closetId) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ClosetDetailNotifier(repo, closetId);
});