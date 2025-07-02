// lib/screens/calendar_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/notifiers/log_wear_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/log_wear_state.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const CalendarPage({super.key, this.initialDate});

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
  }

  void _showLogWearActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.checkroom_outlined),
                title: const Text('Select Outfits'),
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
                title: const Text('Select Items'),
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
    final eventsForDay = _selectedDay != null
        ? (calendarState.events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
        : <WornGroup>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Journal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _selectedDay == null ? null : () => _showLogWearActionSheet(context),
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add'),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<WornGroup>(
            headerStyle: const HeaderStyle(
              formatButtonShowsNext: false,
            ),
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
            child: _buildEventList(eventsForDay),
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

  Widget _buildEventList(List<WornGroup> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text("No items logged for this day."));
    }

    // 1. "Làm phẳng" danh sách: chuyển List<WornGroup> thành List<Widget>
    List<Widget> builtRows = [];
    // Sắp xếp: outfit lên trước, item lẻ xuống sau
    groups.sort((a, b) => (a.outfit == null ? 1 : 0).compareTo(b.outfit == null ? 1 : 0));

    for (var group in groups) {
      if (group.outfit != null) {
        // Nếu là outfit, tạo 1 hàng cho cả outfit
        builtRows.add(_buildOutfitRow(group.outfit!));
      } else {
        // Nếu là item lẻ, tạo một hàng cho MỖI item
        for (var item in group.items) {
          builtRows.add(_buildIndividualItemRow(item));
        }
      }
    }

    // 2. Dùng ListView.separated để hiển thị danh sách widget đã được tạo
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: builtRows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return builtRows[index];
      },
    );
  }

  // Widget để hiển thị một hàng Outfit
  Widget _buildOutfitRow(Outfit outfit) {
    return Row(
      children: [
        // Khung ảnh 3:4 cho outfit
        SizedBox(
          width: 84,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              // Hiển thị ảnh thumbnail của outfit
              child: Image.file(
                File(outfit.thumbnailPath ?? outfit.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Thông tin outfit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("Outfit", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  // Widget để hiển thị một hàng Item lẻ
  Widget _buildIndividualItemRow(ClothingItem item) {
    return Row(
      children: [
        // Khung ảnh 3:4 cho item
        SizedBox(
          width: 84,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
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
        // Thông tin item
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(item.category, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}