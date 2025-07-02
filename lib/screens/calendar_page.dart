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
    groups.sort((a, b) => (a.outfit == null ? 1 : 0).compareTo(b.outfit == null ? 1 : 0));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = groups[index];
        final bool isOutfit = group.outfit != null;
        
        // Bọc toàn bộ hàng trong một Dismissible
        return Dismissible(
          // Key phải là duy nhất để Flutter xác định đúng widget
          key: ValueKey('worn_group_${group.logIds.join("-")}'),
          direction: DismissDirection.endToStart, // Chỉ cho phép vút từ phải sang trái
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          // Hiển thị hộp thoại xác nhận trước khi xóa
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: Text(isOutfit
                    ? "Are you sure you want to remove the outfit '${group.outfit!.name}' from this day's journal?"
                    : "Are you sure you want to remove ${group.items.length} item(s) from this day's journal?"),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ?? false; // Nếu người dùng đóng dialog, mặc định là false
          },
          // Hành động sau khi đã xác nhận xóa
          onDismissed: (direction) {
            ref.read(calendarProvider.notifier).deleteWornGroup(group);
          },
          // Nội dung của hàng
          child: isOutfit
              ? _buildOutfitRow(group.outfit!)
              : _buildIndividualItemsCard(group.items),
        );
      },
    );
  }

  Widget _buildIndividualItemsCard(List<ClothingItem> items) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      // <<< THÊM DÒNG NÀY ĐỂ ĐẶT MÀU NỀN TRẮNG >>>
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        // Mỗi item trong nhóm item lẻ sẽ là một hàng
        child: Column(
          children: items.map((item) => _buildIndividualItemRow(item)).toList(),
        ),
      ),
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