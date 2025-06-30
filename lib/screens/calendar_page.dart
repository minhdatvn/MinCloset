// lib/screens/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final events = calendarState.events;
    final selectedDayEvents = _selectedDay != null
        ? (events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
        : <ClothingItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<ClothingItem>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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