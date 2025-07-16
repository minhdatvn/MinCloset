// lib/notifiers/closet_detail_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/delete_multiple_items_use_case.dart';
import 'package:mincloset/domain/use_cases/move_multiple_items_use_case.dart';
import 'package:mincloset/models/notification_type.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/states/closet_detail_state.dart';

const _pageSize = 18;

class ClosetDetailNotifier extends StateNotifier<ClosetDetailState> {
  final ClothingItemRepository _repo;
  final DeleteMultipleItemsUseCase _deleteMultipleItemsUseCase;   // <<< Khai báo các UseCase dependencies >>>
  final MoveMultipleItemsUseCase _moveMultipleItemsUseCase;
  final Ref _ref;
  final String _closetId;
  final NotificationService _notificationService;
  Timer? _debounce;
  bool _isDisposed = false;

  // <<< Truyền dependencies vào constructor >>>
  ClosetDetailNotifier(
    this._repo,
    this._deleteMultipleItemsUseCase,
    this._moveMultipleItemsUseCase,
    this._ref,
    this._closetId,
    this._notificationService,
  ) : super(const ClosetDetailState()) {
    fetchInitialItems();
    _ref.listen<int>(itemChangedTriggerProvider, (previous, next) {
      if (previous != next) {
        fetchInitialItems();
      }
    });
  }

  // Các hàm từ _fetchPage đến clearSelectionAndExitMode không thay đổi
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
    final count = state.selectedItemIds.length;
    final result = await _deleteMultipleItemsUseCase.execute(state.selectedItemIds); // <<< Sử dụng UseCase đã được inject >>>
    result.fold(
      (failure) => _notificationService.showBanner(message: failure.message), // Banner thất bại
      (_) {
        _notificationService.showBanner( // Banner thành công
          message: 'Successfully deleted $count item(s).',
          type: NotificationType.success,
        );
        _ref.read(itemChangedTriggerProvider.notifier).state++;
        clearSelectionAndExitMode();
        fetchInitialItems();
      },
    );
  }

  Future<void> moveSelectedItems(String targetClosetId) async {
    if (state.selectedItemIds.isEmpty) return;
    final count = state.selectedItemIds.length;
    final result = await _moveMultipleItemsUseCase.execute(state.selectedItemIds, targetClosetId); // <<< Sử dụng UseCase đã được inject >>>
    result.fold(
      (failure) => _notificationService.showBanner(message: failure.message), // Banner thất bại
      (_) {
        _notificationService.showBanner( // Banner thành công
          message: 'Successfully moved $count item(s).',
          type: NotificationType.success,
        );
        clearSelectionAndExitMode();
        fetchInitialItems();
      },
    );
  }
}

final closetDetailProvider = StateNotifierProvider.autoDispose
    .family<ClosetDetailNotifier, ClosetDetailState, String>((ref, closetId) {
  final repo = ref.watch(clothingItemRepositoryProvider);   // <<< Lấy dependency và truyền vào Notifier >>>
  final deleteUseCase = ref.watch(deleteMultipleItemsUseCaseProvider);
  final moveUseCase = ref.watch(moveMultipleItemsUseCaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ClosetDetailNotifier(repo, deleteUseCase, moveUseCase, ref, closetId, notificationService);
});