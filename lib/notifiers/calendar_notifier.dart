// lib/notifiers/calendar_notifier.dart
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/models/wear_log.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/wear_log_repository.dart';
import 'package:mincloset/services/notification_service.dart';
import 'package:mincloset/states/log_wear_state.dart';
import 'package:mincloset/utils/logger.dart';

// State cho Calendar
class WornGroup extends Equatable {
  final Outfit? outfit;
  final List<ClothingItem> items;
  final List<int> logIds;

  const WornGroup({this.outfit, required this.items, required this.logIds});
  
  @override
  List<Object?> get props => [outfit, items, logIds];
}

class CalendarState extends Equatable {
  final Map<DateTime, List<WornGroup>> events;
  final bool isLoading;
  final bool isMultiSelectMode;
  final Set<int> selectedLogIds;

  const CalendarState({
    this.events = const {},
    this.isLoading = true,
    this.isMultiSelectMode = false,
    this.selectedLogIds = const {},
  });

  CalendarState copyWith({
    Map<DateTime, List<WornGroup>>? events,
    bool? isLoading,
    bool? isMultiSelectMode,
    Set<int>? selectedLogIds,
  }) {
    return CalendarState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedLogIds: selectedLogIds ?? this.selectedLogIds,
    );
  }

  @override
  List<Object> get props => [events, isLoading, isMultiSelectMode, selectedLogIds];
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final WearLogRepository _wearLogRepo;
  final ClothingItemRepository _itemRepo;
  final OutfitRepository _outfitRepo;
  final NotificationService _notificationService;

  CalendarNotifier(
    this._wearLogRepo, 
    this._itemRepo, 
    this._outfitRepo,
    this._notificationService,
  ) : super(const CalendarState()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = const CalendarState(isLoading: true);

    final results = await Future.wait([
      _wearLogRepo.getLogsForDateRange(DateTime.now().subtract(const Duration(days: 365)), DateTime.now().add(const Duration(days: 365))),
      _itemRepo.getAllItems(),
      _outfitRepo.getOutfits(),
    ]);

    final logsEither = results[0] as Either<dynamic, List<WearLog>>;
    final itemsEither = results[1] as Either<dynamic, List<ClothingItem>>;
    final outfitsEither = results[2] as Either<dynamic, List<Outfit>>;

    if (logsEither.isLeft() || itemsEither.isLeft() || outfitsEither.isLeft()) {
      state = const CalendarState(isLoading: false);
      return;
    }
    
    final allLogs = logsEither.getOrElse((_) => []);
    final allItems = itemsEither.getOrElse((_) => []);
    final allOutfits = outfitsEither.getOrElse((_) => []);

    final itemMap = {for (var item in allItems) item.id: item};
    final outfitMap = {for (var o in allOutfits) o.id: o};

    final groupedByDate = groupBy(allLogs, (WearLog log) => DateTime(log.wearDate.year, log.wearDate.month, log.wearDate.day));

    final Map<DateTime, List<WornGroup>> finalEvents = {};

    groupedByDate.forEach((date, logsForDay) {
      final List<WornGroup> groupsForDay = [];
      final logsByOutfit = groupBy(logsForDay, (log) => log.outfitId);

      logsByOutfit.forEach((outfitId, outfitLogs) {
        if (outfitId != null) {
          final outfitDetails = outfitMap[outfitId];
          final itemsInOutfit = outfitLogs.map((log) => itemMap[log.itemId]).whereType<ClothingItem>().toList();
          final logIds = outfitLogs.map((log) => log.id).toList(); 

          if (outfitDetails != null && itemsInOutfit.isNotEmpty) {
            groupsForDay.add(WornGroup(outfit: outfitDetails, items: itemsInOutfit, logIds: logIds));
          }
        }
      });

      final individualItemsLogs = logsByOutfit[null] ?? [];
      for (final log in individualItemsLogs) {
        final item = itemMap[log.itemId];
        if (item != null) {
          groupsForDay.add(WornGroup(items: [item], logIds: [log.id]));
        }
      }

      finalEvents[date] = groupsForDay;
    });

    state = state.copyWith(isLoading: false, events: finalEvents);
  }

  void enableMultiSelectMode(List<int> logIds) {
    state = state.copyWith(isMultiSelectMode: true, selectedLogIds: logIds.toSet());
  }
  
  void toggleSelection(List<int> logIds) {
    if (!state.isMultiSelectMode) return;

    final newSet = Set<int>.from(state.selectedLogIds);
    if (newSet.containsAll(logIds)) {
      newSet.removeAll(logIds);
    } else {
      newSet.addAll(logIds);
    }
    
    if (newSet.isEmpty) {
      clearMultiSelectMode();
    } else {
      state = state.copyWith(selectedLogIds: newSet);
    }
  }

  void clearMultiSelectMode() {
    state = state.copyWith(isMultiSelectMode: false, selectedLogIds: {});
  }
  
  Future<void> deleteSelected() async {
    if (state.selectedLogIds.isEmpty) return;
    await deleteWornGroup(WornGroup(logIds: state.selectedLogIds.toList(), items: []));
    clearMultiSelectMode();
  }

  Future<bool> logWearForDate(DateTime date, Set<String> ids, SelectionType type) async {
    if (ids.isEmpty) return false;

    final dateString = date.toIso8601String().split('T').first;
    List<Map<String, dynamic>> logsToInsert = [];

    if (type == SelectionType.items) {
      for (final itemId in ids) {
        logsToInsert.add({
          'item_id': itemId,
          'outfit_id': null,
          'wear_date': dateString,
        });
      }
    } else {
      final outfitsEither = await _outfitRepo.getOutfits();
      outfitsEither.fold(
        (l) => null, // Không làm gì nếu không lấy được danh sách outfits
        (allOutfits) {
          final Map<String, Outfit> outfitMap = {for (var o in allOutfits) o.id: o};
          for (final outfitId in ids) {
            final outfit = outfitMap[outfitId];
            if (outfit != null) {
              final itemIdsInOutfit = outfit.itemIds.split(',');
              for (final itemId in itemIdsInOutfit) {
                if (itemId.isNotEmpty) {
                  logsToInsert.add({
                    'item_id': itemId,
                    'outfit_id': outfitId,
                    'wear_date': dateString,
                  });
                }
              }
            }
          }
        },
      );
    }

    if (logsToInsert.isEmpty) return false;

    final result = await _wearLogRepo.addBatchWearLogs(logsToInsert);
    // Sử dụng fold để xử lý kết quả và trả về true/false
    return result.fold(
      (l) {
        logger.e("Error logging wear", error: l.message);
        _notificationService.showBanner(message: "Failed to log wear: ${l.message}");
        return false; // Trả về false khi thất bại
      },
      (_) {
        loadEvents(); // Tải lại sự kiện
        return true; // Trả về true khi thành công
      },
    );
  }

  // --- HÀM NÀY ĐÃ ĐƯỢC DI CHUYỂN RA NGOÀI ---
  Future<void> deleteWornGroup(WornGroup group) async {
    if (group.logIds.isEmpty) return;

    final result = await _wearLogRepo.deleteWearLogs(group.logIds);
    result.fold(
      (l) => logger.e("Error deleting wear logs", error: l.message),
      (_) => loadEvents(),
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final wearLogRepo = ref.watch(wearLogRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return CalendarNotifier(wearLogRepo, itemRepo, outfitRepo, notificationService);
});