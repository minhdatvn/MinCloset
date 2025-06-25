// lib/notifiers/item_filter_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/item_filter_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:mincloset/domain/providers.dart';

const _pageSize = 15;

class ItemFilterNotifier extends StateNotifier<ItemFilterState> {
  final ClothingItemRepository _repo;
  final Ref _ref;
  Timer? _debounce;
  bool _isDisposed = false;

  ItemFilterNotifier(this._repo, this._ref) : super(const ItemFilterState()) {
    fetchInitialItems();

    _ref.listen<int>(itemAddedTriggerProvider, (previous, next) {
      if (previous != next) {
        fetchInitialItems();
      }
    });
  }

  Future<void> _fetchPage(int page) async {
    try {
      // <<< SỬA ĐỔI QUAN TRỌNG: Gọi hàm lọc mới >>>
      final newItems = await _repo.getFilteredItems(
        query: state.searchQuery,
        filters: state.activeFilters, // Truyền cả bộ lọc vào
        limit: _pageSize,
        offset: page * _pageSize,
      );

      if (_isDisposed) return;

      final currentItems = (page == 0) ? <ClothingItem>[] : state.items;
      
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        items: [...currentItems, ...newItems],
        hasMore: newItems.length == _pageSize,
      );
    } catch (e, s) {
      if (_isDisposed) return;
      logger.e("Failed to load items", error: e, stackTrace: s);
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

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      // Chỉ cập nhật state và tải lại, không cần so sánh query cũ
      state = state.copyWith(searchQuery: query);
      fetchInitialItems();
    });
  }

  void applyFilters(OutfitFilter filters) {
    state = state.copyWith(activeFilters: filters);
    fetchInitialItems();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }

  void enableMultiSelectMode(String initialItemId) {
    state = state.copyWith(
      isMultiSelectMode: true,
      selectedItemIds: {initialItemId},
    );
  }

  void toggleItemSelection(String itemId) {
    if (!state.isMultiSelectMode) return;

    final newSet = Set<String>.from(state.selectedItemIds);
    if (newSet.contains(itemId)) {
      newSet.remove(itemId);
    } else {
      newSet.add(itemId);
    }
    
    // Nếu không còn item nào được chọn, thoát khỏi chế độ multi-select
    if (newSet.isEmpty) {
      clearSelectionAndExitMode();
    } else {
      state = state.copyWith(selectedItemIds: newSet);
    }
  }

  void clearSelectionAndExitMode() {
    state = state.copyWith(
      isMultiSelectMode: false,
      selectedItemIds: {},
    );
  }

  Future<void> deleteSelectedItems() async {
    if (state.selectedItemIds.isEmpty) return;

    final useCase = _ref.read(deleteMultipleItemsUseCaseProvider);
    await useCase.execute(state.selectedItemIds);
    
    // Sau khi xóa, thoát chế độ và tải lại dữ liệu
    clearSelectionAndExitMode();
    await fetchInitialItems();
  }
}

final itemFilterProvider = StateNotifierProvider.autoDispose
    .family<ItemFilterNotifier, ItemFilterState, String>((ref, id) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ItemFilterNotifier(repo, ref);
});