// lib/screens/calendar_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/context_extensions.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/notifiers/item_detail_notifier.dart';
import 'package:mincloset/notifiers/log_wear_notifier.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/log_wear_state.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final bool showHintOnLoad;
  const CalendarPage({super.key, this.initialDate, this.showHintOnLoad = false});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = widget.initialDate ?? _focusedDay;

    if (widget.showHintOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ShowCaseWidget.of(context).startShowCase([QuestHintKeys.logWearHintKey]);
        }
      });
    }
  }

  void _showLogWearActionSheet(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.checkroom_outlined),
                title: Text(l10n.calendar_selectOutfits),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final selectedIds = await Navigator.pushNamed<Set<String>>(
                    context,
                    AppRoutes.logWearSelection,
                    arguments: LogWearNotifierArgs(type: SelectionType.outfits),
                  );

                  if (mounted && _selectedDay != null && selectedIds != null && selectedIds.isNotEmpty) {
                    ref.read(calendarProvider.notifier).logWearForDate(_selectedDay!, selectedIds, SelectionType.outfits);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.style_outlined),
                title: Text(l10n.calendar_selectItems),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final selectedIds = await Navigator.pushNamed<Set<String>>(
                    context,
                    AppRoutes.logWearSelection,
                    arguments: LogWearNotifierArgs(type: SelectionType.items),
                  );

                  if (mounted && _selectedDay != null && selectedIds != null && selectedIds.isNotEmpty) {
                    ref.read(calendarProvider.notifier).logWearForDate(_selectedDay!, selectedIds, SelectionType.items);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final eventsForDay = _selectedDay != null
        ? (calendarState.events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
        : <WornGroup>[];
    
    // <<< THAY ĐỔI 2: Logic đếm số nhóm đã chọn >>>
    final selectedGroupCount = eventsForDay.where((group) {
      return calendarState.selectedLogIds.containsAll(group.logIds);
    }).length;
    final l10n = context.l10n;
    final Map<CalendarFormat, String> localizedHeaderFormats = {
      CalendarFormat.month: l10n.calendar_formatMonth,
      CalendarFormat.twoWeeks: l10n.calendar_formatTwoWeeks,
      CalendarFormat.week: l10n.calendar_formatWeek,
    };

    return PageScaffold(
      appBar: calendarState.isMultiSelectMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: notifier.clearMultiSelectMode,
              ),
              // Hiển thị số nhóm đã chọn
              title: Text(l10n.closets_itemsSelected(selectedGroupCount)),
              actions: [
                IconButton(
                  // <<< THAY ĐỔI 1: Đổi màu icon thùng rác >>>
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await showDeleteConfirmationDialog(
                      context,
                      title: l10n.calendar_deleteDialogTitle,
                      content: Text(l10n.calendar_deleteDialogContent(selectedGroupCount)),
                    );
                    if (confirmed == true) {
                      await notifier.deleteSelected();
                    }
                  },
                )
              ],
            )
          // AppBar mặc định
          : AppBar(
              title: Text(l10n.calendar_title),
              actions: [
                Showcase(
                  key: QuestHintKeys.logWearHintKey,
                  title: l10n.calendar_logWearHintTitle,
                  description: l10n.calendar_logWearHintDescription,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton.icon(
                      onPressed: _selectedDay == null
                          ? null
                          : () => _showLogWearActionSheet(context),
                      icon: const Icon(Icons.add_task_outlined),
                      label: Text(l10n.calendar_addLogButton),
                    ),
                  ),
                ),
              ],
            ),
      body: Column(
        children: [
          TableCalendar<WornGroup>(
            locale: Localizations.localeOf(context).toString(),
            headerStyle: const HeaderStyle(
              formatButtonShowsNext: false,
            ),
            
            availableCalendarFormats: localizedHeaderFormats,
            
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() { _calendarFormat = format; });
              }
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return calendarState.events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            daysOfWeekHeight: 30.0,
            calendarStyle: CalendarStyle(
              // Tùy chỉnh cho ngày được chọn (Selected Day)
              selectedDecoration: BoxDecoration(
                color: const Color(0xFF98D8C8), // <-- MÀU XANH BẠC HÀ ĐẬM
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),

              // Tùy chỉnh cho ngày hôm nay (Today)
              todayDecoration: BoxDecoration(
                color: const Color(0xFFE0F2F1), // <-- MÀU XANH BẠC HÀ NHẠT
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.teal.shade800),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(events),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(eventsForDay, calendarState, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(List<dynamic> groups) {
    final allItemsInDay = groups.cast<WornGroup>().expand((group) => group.items);
    final uniqueItemCount = allItemsInDay.toSet().length;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withAlpha(200),
      ),
      child: Center(
        child: Text(
          '$uniqueItemCount',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }

  // <<< BẮT ĐẦU CẬP NHẬT TỪ ĐÂY >>>

  Widget _buildEventList(List<WornGroup> groups, CalendarState calendarState, CalendarNotifier notifier) {
    final l10n = context.l10n;
    if (groups.isEmpty) {
      return Center(child: Text(l10n.calendar_noItemsLogged));
    }
    groups.sort((a, b) => (a.outfit == null ? 1 : 0).compareTo(b.outfit == null ? 1 : 0));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        final isOutfit = group.outfit != null;
        final isSelected = calendarState.selectedLogIds.containsAll(group.logIds);

        // Bọc GestureDetector ra ngoài cùng để có vùng nhấn lớn nhất
        return GestureDetector(
          // <<< SỬA LỖI 2: Thêm behavior: HitTestBehavior.opaque >>>
          behavior: HitTestBehavior.opaque,
          onLongPress: () {
            notifier.enableMultiSelectMode(group.logIds);
          },
          onTap: () {
            // Trường hợp 1: Đang ở chế độ đa chọn
            if (calendarState.isMultiSelectMode) {
              notifier.toggleSelection(group.logIds);
            } 
            // Trường hợp 2: Đang ở chế độ bình thường
            else {
              if (isOutfit) {
                // Điều hướng đến trang chi tiết Outfit
                Navigator.pushNamed(
                  context,
                  AppRoutes.outfitDetail,
                  arguments: group.outfit!,
                ).then((wasChanged) {
                  // Sau khi quay lại, kiểm tra xem có cần làm mới không
                  if (wasChanged == true) {
                    notifier.loadEvents();
                  }
                });
              } else {
                // Điều hướng đến trang sửa Item
                final item = group.items.first;
                Navigator.pushNamed(
                  context,
                  AppRoutes.addItem,
                  arguments: ItemDetailNotifierArgs(itemToEdit: item, tempId: item.id),
                ).then((wasChanged) {
                  // Sau khi quay lại, kiểm tra xem có cần làm mới không
                  if (wasChanged == true) {
                    notifier.loadEvents();
                  }
                });
              }
            }
          },
          child: Card(
            // <<< SỬA LỖI 1: Thêm color: Colors.white >>>
            surfaceTintColor: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            // Đặt Dismissible bên trong để nó không ảnh hưởng đến vùng nhấn
            child: Dismissible(
              key: ValueKey('worn_group_${group.logIds.join("-")}'),
              direction: calendarState.isMultiSelectMode ? DismissDirection.none : DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                  return await showDeleteConfirmationDialog(
                    context,
                    title: l10n.calendar_deleteDialogTitle,
                    content: Text(isOutfit
                        ? l10n.calendar_deleteDialogContentOutfit(group.outfit!.name)
                        : l10n.calendar_deleteDialogContentItem(group.items.first.name)),
                  );
              },
              onDismissed: (direction) {
                notifier.deleteWornGroup(group);
              },
              child: isOutfit
                  ? _buildOutfitRow(group.outfit!)
                  : _buildIndividualItemRow(group.items.first),
            ),
          ),
        );
      },
    );
  }

  // Widget để hiển thị một hàng Outfit
  Widget _buildOutfitRow(Outfit outfit) {
    final l10n = context.l10n;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(outfit.thumbnailPath ?? outfit.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(l10n.calendar_outfitLabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget để hiển thị một hàng Item lẻ
  Widget _buildIndividualItemRow(ClothingItem item) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.file(
                  File(item.thumbnailPath ?? item.imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(item.category, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}