// lib/widgets/weekly_planner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/day_planner_card.dart';
import 'package:mincloset/widgets/section_header.dart';

class WeeklyPlanner extends ConsumerStatefulWidget {
  const WeeklyPlanner({super.key});

  @override
  ConsumerState<WeeklyPlanner> createState() => _WeeklyPlannerState();
}

class _WeeklyPlannerState extends ConsumerState<WeeklyPlanner> {
  late final ScrollController _scrollController;
  final double _cardWidth = 110.0; 

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final scrollableAreaCenter = (screenWidth - 32.0) / 2;
        final todayCardCenter = 3.5 * _cardWidth;
        final targetOffset = todayCardCenter - scrollableAreaCenter;
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final events = calendarState.events;

    final today = DateTime.now();
    final days = List.generate(7, (index) => today.add(Duration(days: index - 3)));

    return Column(
      children: [
        SectionHeader(
          title: "Week's Journal",
          seeAllText: 'View more',
          onSeeAll: () {
            Navigator.pushNamed(context, AppRoutes.calendar);
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (ctx, index) {
              final day = days[index];
              final isToday = index == 3;
              String dayLabel = isToday ? 'Today' : DateFormat('E').format(day);

              // <<< BẮT ĐẦU THAY ĐỔI TẠI ĐÂY >>>

              // 1. Lấy danh sách các WornGroup cho ngày hiện tại
              final dayGroups = events[DateTime(day.year, day.month, day.day)] ?? [];

              // 2. "Làm phẳng" danh sách các nhóm thành một danh sách các item
              final itemsForDay = dayGroups.expand((group) => group.items).toList();

              // 3. Lấy đường dẫn ảnh từ danh sách item đã được làm phẳng
              final imagePaths = itemsForDay.map((item) => item.thumbnailPath ?? item.imagePath).toList();

              return DayPlannerCard(
                dayLabel: dayLabel,
                isToday: isToday,
                itemImagePaths: imagePaths, // Truyền danh sách đường dẫn ảnh đúng
                onAdd: () {
                  Navigator.pushNamed(context, AppRoutes.calendar, arguments: day);
                },
              );

              // <<< KẾT THÚC THAY ĐỔI >>>
            },
          ),
        ),
      ],
    );
  }
}