// lib/notifiers/calendar_notifier.dart
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart'; // <<< THÊM IMPORT
import 'package:mincloset/models/wear_log.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart'; // <<< THÊM IMPORT
import 'package:mincloset/repositories/wear_log_repository.dart';
import 'package:mincloset/states/log_wear_state.dart'; // <<< THÊM IMPORT
import 'package:mincloset/utils/logger.dart'; // <<< THÊM IMPORT LOGGER

// State cho Calendar
class WornGroup extends Equatable {
  final Outfit? outfit;
  final List<ClothingItem> items;
  final List<int> logIds; // Danh sách các ID của bản ghi wear_log

  const WornGroup({this.outfit, required this.items, required this.logIds});
  
  @override
  List<Object?> get props => [outfit, items, logIds];
}


// <<< THAY ĐỔI: State giờ sẽ chứa một Map<DateTime, List<WornGroup>> >>>
class CalendarState extends Equatable {
  final Map<DateTime, List<WornGroup>> events;
  final bool isLoading;

  const CalendarState({this.events = const {}, this.isLoading = true});

  @override
  List<Object> get props => [events, isLoading];
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final WearLogRepository _wearLogRepo;
  final ClothingItemRepository _itemRepo;
  final OutfitRepository _outfitRepo;

  CalendarNotifier(this._wearLogRepo, this._itemRepo, this._outfitRepo) : super(const CalendarState()) {
    loadEvents();
  }

  // <<< THAY ĐỔI HOÀN TOÀN LOGIC CỦA HÀM NÀY >>>
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

    // Xử lý khi có lỗi xảy ra ở bất kỳ đâu
    if (logsEither.isLeft() || itemsEither.isLeft() || outfitsEither.isLeft()) {
      state = const CalendarState(isLoading: false);
      return;
    }
    
    final allLogs = logsEither.getOrElse((_) => []);
    final allItems = itemsEither.getOrElse((_) => []);
    final allOutfits = outfitsEither.getOrElse((_) => []);

    // Tạo các map để tra cứu nhanh
    final itemMap = {for (var item in allItems) item.id: item};
    final outfitMap = {for (var o in allOutfits) o.id: o};

    // Nhóm tất cả các log theo ngày
    final groupedByDate = groupBy(allLogs, (WearLog log) => DateTime(log.wearDate.year, log.wearDate.month, log.wearDate.day));

    final Map<DateTime, List<WornGroup>> finalEvents = {};

    // Duyệt qua mỗi ngày
    groupedByDate.forEach((date, logsForDay) {
      final List<WornGroup> groupsForDay = [];
      final logsByOutfit = groupBy(logsForDay, (log) => log.outfitId);

      // Xử lý các nhóm outfit
      logsByOutfit.forEach((outfitId, outfitLogs) {
        if (outfitId != null) {
          final outfitDetails = outfitMap[outfitId];
          final itemsInOutfit = outfitLogs.map((log) => itemMap[log.itemId]).whereType<ClothingItem>().toList();
          // Lấy ID của các bản ghi log
          final logIds = outfitLogs.map((log) => log.id).toList(); 

          if (outfitDetails != null && itemsInOutfit.isNotEmpty) {
            groupsForDay.add(WornGroup(outfit: outfitDetails, items: itemsInOutfit, logIds: logIds));
          }
        }
      });

      // Xử lý các item riêng lẻ
      final individualItemsLogs = logsByOutfit[null] ?? [];
      final individualItems = individualItemsLogs.map((log) => itemMap[log.itemId]).whereType<ClothingItem>().toList();
      // Lấy ID của các bản ghi log
      final individualLogIds = individualItemsLogs.map((log) => log.id).toList();

      if (individualItems.isNotEmpty) {
         groupsForDay.add(WornGroup(items: individualItems, logIds: individualLogIds));
      }

      finalEvents[date] = groupsForDay;
    });

    state = CalendarState(isLoading: false, events: finalEvents);
  }

  Future<void> logWearForDate(DateTime date, Set<String> ids, SelectionType type) async {
    if (ids.isEmpty) return;

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
        (l) => null,
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

    if (logsToInsert.isNotEmpty) {
      final result = await _wearLogRepo.addBatchWearLogs(logsToInsert);
      result.fold(
        // <<< THAY ĐỔI: Dùng logger.e để ghi nhận lỗi >>>
        (l) => logger.e("Error logging wear", error: l.message),
        (_) => loadEvents(),
      );
    }
  }

  Future<void> deleteWornGroup(WornGroup group) async {
    if (group.logIds.isEmpty) return;

    final result = await _wearLogRepo.deleteWearLogs(group.logIds);
    result.fold(
      (l) => logger.e("Error deleting wear logs", error: l.message),
      (_) => loadEvents(), // Tải lại sự kiện sau khi xóa thành công
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final wearLogRepo = ref.watch(wearLogRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return CalendarNotifier(wearLogRepo, itemRepo, outfitRepo);
});