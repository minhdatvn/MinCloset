// lib/notifiers/item_filter_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart'; // <<< THÊM DÒNG IMPORT QUAN TRỌNG NÀY
import 'package:mincloset/models/outfit_filter.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/item_filter_state.dart';
import 'package:mincloset/utils/logger.dart';

class ItemFilterNotifier extends StateNotifier<ItemFilterState> {
  final ClothingItemRepository _repo;
  Timer? _debounce;

  ItemFilterNotifier(this._repo) : super(const ItemFilterState()) {
    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repo.getAllItems();
      if (mounted) {
        state = state.copyWith(
            allItems: items, filteredItems: items, isLoading: false);
      }
    } catch (e, s) {
      logger.e("Lỗi khi tải tất cả vật phẩm", error: e, stackTrace: s);
      if (mounted) {
        state = state.copyWith(
            errorMessage: "Lỗi tải vật phẩm", isLoading: false);
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
    if (_debounce?.isActive ?? false) _debounce!.cancel();
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
        results.retainWhere((item) => item.category.startsWith(filters.category!));
      }
      if (filters.colors.isNotEmpty) {
        results.retainWhere((item) => filters.colors.any((color) => item.color.contains(color)));
      }
      if (filters.seasons.isNotEmpty) {
        results.retainWhere((item) => filters.seasons.any((season) => item.season?.contains(season) ?? false));
      }
      if (filters.occasions.isNotEmpty) {
        results.retainWhere((item) => filters.occasions.any((occasion) => item.occasion?.contains(occasion) ?? false));
      }
    }

    if (state.searchQuery.isNotEmpty) {
      results.retainWhere((item) => item.name.toLowerCase().contains(state.searchQuery.toLowerCase()));
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
  return ItemFilterNotifier(repo);
});