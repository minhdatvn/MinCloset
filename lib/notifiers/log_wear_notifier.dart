// lib/notifiers/log_wear_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/states/log_wear_state.dart';

// Tham số để khởi tạo Notifier
class LogWearNotifierArgs {
  final SelectionType type;
  final Set<String> initialIds;

  LogWearNotifierArgs({required this.type, this.initialIds = const {}});
}

const _pageSize = 21;

class LogWearNotifier extends StateNotifier<LogWearState> {
  final Ref _ref;
  final LogWearNotifierArgs _args;

  LogWearNotifier(this._ref, this._args)
      : super(LogWearState(selectedIds: _args.initialIds)) {
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    state = state.copyWith(isLoading: true, allData: [], hasMore: true, clearError: true);
    await _fetchPage(0);
  }

  Future<void> _fetchPage(int page) async {
    dynamic result;

    if (_args.type == SelectionType.items) {
      final repo = _ref.read(clothingItemRepositoryProvider);
      result = await repo.getAllItems(limit: _pageSize, offset: page * _pageSize);
    } else {
      final repo = _ref.read(outfitRepositoryProvider);
      result = await repo.getOutfits(limit: _pageSize, offset: page * _pageSize);
    }
    
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: failure.message),
      (newData) {
        final currentData = (page == 0) ? [] : state.allData;
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          allData: [...currentData, ...newData],
          hasMore: newData.length == _pageSize,
        );
      },
    );
  }

  void fetchMoreData() {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = (state.allData.length / _pageSize).floor();
    _fetchPage(nextPage);
  }

  void toggleSelection(String id) {
    final newSet = Set<String>.from(state.selectedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = state.copyWith(selectedIds: newSet);
  }
}

final logWearProvider =
    StateNotifierProvider.autoDispose.family<LogWearNotifier, LogWearState, LogWearNotifierArgs>(
  (ref, args) => LogWearNotifier(ref, args),
);