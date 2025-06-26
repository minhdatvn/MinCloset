// lib/notifiers/closet_detail_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/closet_detail_state.dart';

const _pageSize = 18;

class ClosetDetailNotifier extends StateNotifier<ClosetDetailState> {
  final ClothingItemRepository _repo;
  final Ref _ref;
  final String _closetId;
  Timer? _debounce;
  bool _isDisposed = false;

  ClosetDetailNotifier(this._repo, this._ref, this._closetId) : super(const ClosetDetailState()) {
    fetchInitialItems();
  }

  Future<void> _fetchPage(int page) async {
    final result = await _repo.searchItemsInCloset(
      _closetId,
      state.searchQuery,
      limit: _pageSize,
      offset: page * _pageSize,
    );

    if (_isDisposed) return;

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: failure.message),
      (newItems) {
        final currentItems = (page == 0) ? [] : state.items;
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          items: [...currentItems, ...newItems],
          hasMore: newItems.length == _pageSize,
          page: page + 1, // Cập nhật trang tiếp theo
        );
      },
    );
  }

  Future<void> fetchInitialItems() async {
    state = state.copyWith(isLoading: true, items: [], hasMore: true, page: 0, clearError: true);
    await _fetchPage(0);
  }

  Future<void> fetchMoreItems() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchPage(state.page);
  }
  
  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(searchQuery: query, page: 0);
      fetchInitialItems();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }

  void enableMultiSelectMode(String initialItemId) {
    state = state.copyWith(isMultiSelectMode: true, selectedItemIds: {initialItemId});
  }

  void toggleItemSelection(String itemId) {
    if (!state.isMultiSelectMode) return;
    final newSet = Set<String>.from(state.selectedItemIds);
    if (newSet.contains(itemId)) {
      newSet.remove(itemId);
    } else {
      newSet.add(itemId);
    }
    if (newSet.isEmpty) {
      clearSelectionAndExitMode();
    } else {
      state = state.copyWith(selectedItemIds: newSet);
    }
  }

  void clearSelectionAndExitMode() {
    state = state.copyWith(isMultiSelectMode: false, selectedItemIds: {});
  }

  Future<void> deleteSelectedItems() async {
    if (state.selectedItemIds.isEmpty) return;
    final useCase = _ref.read(deleteMultipleItemsUseCaseProvider);
    final result = await useCase.execute(state.selectedItemIds);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        _ref.read(itemChangedTriggerProvider.notifier).state++;
        clearSelectionAndExitMode();
        fetchInitialItems();
      },
    );
  }

  Future<void> moveSelectedItems(String targetClosetId) async {
    if (state.selectedItemIds.isEmpty) return;
    final useCase = _ref.read(moveMultipleItemsUseCaseProvider);
    final result = await useCase.execute(state.selectedItemIds, targetClosetId);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        clearSelectionAndExitMode();
        fetchInitialItems();
      },
    );
  }
}

final closetDetailProvider = StateNotifierProvider.autoDispose
    .family<ClosetDetailNotifier, ClosetDetailState, String>((ref, closetId) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ClosetDetailNotifier(repo, ref, closetId);
});