// lib/notifiers/item_filter_notifier.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/item_filter_state.dart';

const _pageSize = 15;

class ItemFilterNotifier extends StateNotifier<ItemFilterState> {
  final ClothingItemRepository _repo;
  final Ref _ref;
  Timer? _debounce;
  bool _isDisposed = false;

  ItemFilterNotifier(this._repo, this._ref) : super(const ItemFilterState()) {
    fetchInitialItems();

    _ref.listen<int>(itemChangedTriggerProvider, (previous, next) {
      if (previous != next) {
        fetchInitialItems();
      }
    });
  }

  Future<void> _fetchPage(int page) async {
    final result = await _repo.getFilteredItems(
      query: state.searchQuery,
      filters: state.activeFilters,
      limit: _pageSize,
      offset: page * _pageSize,
    );

    if (_isDisposed) return;

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: failure.message),
      (newItems) {
        final currentItems = (page == 0) ? <ClothingItem>[] : state.items;
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          items: [...currentItems, ...newItems],
          hasMore: newItems.length == _pageSize,
          page: page + 1,
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

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(searchQuery: query, page: 0, items: [], hasMore: true);
      fetchInitialItems();
    });
  }

  void applyFilters(OutfitFilter filters) {
    state = state.copyWith(activeFilters: filters, page: 0, items: [], hasMore: true);
    fetchInitialItems();
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
      }
    );
  }
}

final itemFilterProvider = StateNotifierProvider.autoDispose
    .family<ItemFilterNotifier, ItemFilterState, String>((ref, id) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ItemFilterNotifier(repo, ref);
});