// lib/widgets/weekly_planner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/widgets/day_planner_card.dart';
import 'package:mincloset/widgets/section_header.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';

class WeeklyPlanner extends ConsumerWidget { // <<< CHUYỂN THÀNH ConsumerWidget
  const WeeklyPlanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <<< THÊM WidgetRef
    // Lấy dữ liệu thật từ provider
    final calendarState = ref.watch(calendarProvider);
    final events = calendarState.events;

    final today = DateTime.now();
    final days = List.generate(7, (index) => today.add(Duration(days: index - 3)));

    return Column(
      children: [
        SectionHeader(
          title: 'Weekly planner',
          seeAllText: 'View Calendar',
          onSeeAll: () {
            // Điều hướng đến trang lịch đầy đủ
            Navigator.pushNamed(context, AppRoutes.calendar);
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (ctx, index) {
              final day = days[index];
              final isToday = day.day == today.day && day.month == today.month;
              String dayLabel = isToday ? 'Today' : DateFormat('E').format(day);
              
              // Lấy trang phục cho ngày hiện tại
              final dayEvents = events[DateTime(day.year, day.month, day.day)] ?? [];
              
              return DayPlannerCard(
                dayLabel: dayLabel,
                isToday: isToday,
                // TODO: Kết nối thời tiết thật cho 7 ngày
                weatherIcon: Icons.cloud_outlined,
                temperature: '34° 26°',
                itemImagePaths: dayEvents.map((e) => e.thumbnailPath ?? e.imagePath).toList(),
                onAdd: () {
                  // TODO: Logic để chọn outfit cho ngày này
                },
              );
            },
          ),
        ),
      ],
    );
  }
}