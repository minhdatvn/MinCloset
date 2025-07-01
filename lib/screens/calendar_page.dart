// lib/screens/calendar_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
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
    // <<< SỬA LỖI: Sửa lại logic initState >>>
    _focusedDay = widget.initialDate ?? DateTime.now();
    // Chọn ngày được truyền vào hoặc ngày hôm nay làm ngày được chọn mặc định
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
                leading: const Icon(Icons.library_books_outlined),
                title: const Text('Select outfits'),
                onTap: () async {
                  Navigator.of(ctx).pop(); // Đóng bottom sheet trước
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
                leading: const Icon(Icons.dry_cleaning_outlined),
                title: const Text('Select items'),
                onTap: () async {
                  Navigator.of(ctx).pop(); // Đóng bottom sheet trước
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
    final events = calendarState.events;
    final selectedDayEvents = _selectedDay != null
        ? (events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
        : <ClothingItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Style journal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _selectedDay == null
                  ? null
                  : () => _showLogWearActionSheet(context),
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add'),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<ClothingItem>(
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
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return events[DateTime(day.year, day.month, day.day)] ?? [];
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
            child: _buildEventList(selectedDayEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(List<dynamic> events) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withAlpha(200),
      ),
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildEventList(List<ClothingItem> events) {
    if (events.isEmpty) {
      return const Center(child: Text("No outfits logged for this day."));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final item = events[index];
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.file(
              File(item.thumbnailPath ?? item.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          title: Text(item.name),
          subtitle: Text(item.category),
        );
      },
    );
  }
}