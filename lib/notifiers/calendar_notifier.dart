// lib/notifiers/calendar_notifier.dart
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class CalendarState extends Equatable {
  // Map từ ngày sang danh sách các vật phẩm đã mặc
  final Map<DateTime, List<ClothingItem>> events;
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

  Future<void> loadEvents() async {
    state = const CalendarState(isLoading: true);

    final startDate = DateTime.now().subtract(const Duration(days: 365));
    final endDate = DateTime.now().add(const Duration(days: 365));

    final logsEither = await _wearLogRepo.getLogsForDateRange(startDate, endDate);

    await logsEither.fold(
      (l) async => state = const CalendarState(isLoading: false),
      (logs) async {
        final allItemsEither = await _itemRepo.getAllItems();
        await allItemsEither.fold(
          (l) async => state = const CalendarState(isLoading: false),
          (allItems) {
            final Map<String, ClothingItem> itemMap = {
              for (var item in allItems) item.id: item
            };

            final groupedByDate = groupBy(
              logs, (WearLog log) => DateTime(log.wearDate.year, log.wearDate.month, log.wearDate.day)
            );

            final Map<DateTime, List<ClothingItem>> finalEvents = {};
            groupedByDate.forEach((date, dateLogs) {
              final itemsForDay = dateLogs
                  .map((log) => itemMap[log.itemId])
                  .where((item) => item != null)
                  .cast<ClothingItem>()
                  .toList();
              finalEvents[date] = itemsForDay.toSet().toList();
            });

            state = CalendarState(isLoading: false, events: finalEvents);
          }
        );
      }
    );
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
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final wearLogRepo = ref.watch(wearLogRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return CalendarNotifier(wearLogRepo, itemRepo, outfitRepo);
});