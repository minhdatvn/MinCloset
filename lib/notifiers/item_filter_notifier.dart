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

class ItemFilterNotifier extends StateNotifier<ItemFilterState> {
  final ClothingItemRepository _repo;
  final Ref _ref;
  Timer? _debounce;

  ItemFilterNotifier(this._repo, this._ref) : super(const ItemFilterState()) {
    _loadAllItems();

    // Lắng nghe tín hiệu để tự động tải lại danh sách vật phẩm
    _ref.listen<int>(itemAddedTriggerProvider, (previous, next) {
      if (previous != next) {
        _loadAllItems();
      }
    });
  }

  Future<void> _loadAllItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repo.getAllItems();
      if (mounted) {
        state = state.copyWith(
            allItems: items, filteredItems: items, isLoading: false);
        // Sau khi tải lại danh sách gốc, chạy lại bộ lọc hiện tại
        // để đảm bảo danh sách hiển thị được cập nhật đúng.
        _runFilter();
      }
    } catch (e, s) {
      logger.e("Failed to load all items", error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(
            errorMessage: "Failed to load item", isLoading: false);
      }
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _runFilterWithDebounce();
  }

  void applyFilters(OutfitFilter filters) {
    state = state.copyWith(activeFilters: filters);
    _runFilter();
  }

  void clearFilters() {
    state = state.copyWith(
      activeFilters: const OutfitFilter(),
      searchQuery: '',
    );
    _runFilter();
  }

  void _runFilterWithDebounce() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 400), _runFilter);
  }

  void _runFilter() {
    List<ClothingItem> results = List.from(state.allItems);
    final filters = state.activeFilters;

    if (filters.isApplied) {
      if (filters.closetId != null) {
        results.retainWhere((item) => item.closetId == filters.closetId);
      }
      if (filters.category != null) {
        results
            .retainWhere((item) => item.category.startsWith(filters.category!));
      }
      if (filters.colors.isNotEmpty) {
        results.retainWhere(
            (item) => filters.colors.any((color) => item.color.contains(color)));
      }
      if (filters.seasons.isNotEmpty) {
        results.retainWhere((item) =>
            filters.seasons.any((s) => item.season?.contains(s) ?? false));
      }
      if (filters.occasions.isNotEmpty) {
        results.retainWhere((item) =>
            filters.occasions.any((o) => item.occasion?.contains(o) ?? false));
      }
    }

    if (state.searchQuery.isNotEmpty) {
      results.retainWhere(
          (item) => item.name.toLowerCase().contains(state.searchQuery.toLowerCase()));
    }

    if (mounted) {
      state = state.copyWith(filteredItems: results);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final itemFilterProvider = StateNotifierProvider.autoDispose
    .family<ItemFilterNotifier, ItemFilterState, String>((ref, id) {
  final repo = ref.watch(clothingItemRepositoryProvider);
  return ItemFilterNotifier(repo, ref);
});