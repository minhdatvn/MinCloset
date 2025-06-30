// lib/notifiers/calendar_notifier.dart
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/wear_log.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/wear_log_repository.dart';

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

  CalendarNotifier(this._wearLogRepo, this._itemRepo) : super(const CalendarState()) {
    // Tải dữ liệu lần đầu
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = const CalendarState(isLoading: true);

    // Lấy dữ liệu log trong một khoảng thời gian rộng
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

            // Nhóm các logs theo ngày
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
              // Loại bỏ các item trùng lặp trong một ngày
              finalEvents[date] = itemsForDay.toSet().toList();
            });

            state = CalendarState(isLoading: false, events: finalEvents);
          }
        );
      }
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final wearLogRepo = ref.watch(wearLogRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  return CalendarNotifier(wearLogRepo, itemRepo);
});