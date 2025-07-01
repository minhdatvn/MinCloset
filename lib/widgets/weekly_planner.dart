// lib/widgets/weekly_planner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/day_planner_card.dart';
import 'package:mincloset/widgets/section_header.dart';

// <<< THAY ĐỔI 1: Chuyển thành ConsumerStatefulWidget >>>
class WeeklyPlanner extends ConsumerStatefulWidget {
  const WeeklyPlanner({super.key});

  @override
  ConsumerState<WeeklyPlanner> createState() => _WeeklyPlannerState();
}

class _WeeklyPlannerState extends ConsumerState<WeeklyPlanner> {
  // <<< THAY ĐỔI 2: Khai báo ScrollController >>>
  late final ScrollController _scrollController;
  final double _cardWidth = 110.0; // Định nghĩa chiều rộng của mỗi thẻ

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller
    _scrollController = ScrollController();

    // <<< THAY ĐỔI 3: Thêm logic tự động cuộn >>>
    // Dùng addPostFrameCallback để đảm bảo widget đã được vẽ xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ thực hiện khi controller đã được gắn vào ListView
      if (_scrollController.hasClients) {
        // Lấy chiều rộng thực của màn hình
        final screenWidth = MediaQuery.of(context).size.width;

        // Vị trí của thẻ "Today" (thẻ thứ 4, index 3)
        final todayCardCenter = 3.5 * _cardWidth;

        // Tính toán lại tâm của khu vực cuộn bằng cách trừ đi 32px padding (16 trái + 16 phải)
        final scrollableAreaCenter = (screenWidth - 32.0) / 2;

        // Vị trí cuộn mục tiêu mới
        final targetOffset = todayCardCenter - scrollableAreaCenter;

        // Dùng jumpTo để di chuyển ngay lập tức mà không có animation
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  void dispose() {
    // <<< THAY ĐỔI 4: Hủy controller để tránh rò rỉ bộ nhớ >>>
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final events = calendarState.events;

    final today = DateTime.now();
    // Mảng các ngày sẽ bắt đầu từ 3 ngày trước đến 3 ngày sau
    final days = List.generate(7, (index) => today.add(Duration(days: index - 3)));

    return Column(
      children: [
        SectionHeader(
          title: "Week's journal",
          seeAllText: 'View more',
          onSeeAll: () {
            Navigator.pushNamed(context, AppRoutes.calendar);
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            // <<< THAY ĐỔI 5: Gán controller cho ListView >>>
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (ctx, index) {
              final day = days[index];
              // Thẻ "Today" sẽ là thẻ ở giữa, có index = 3
              final isToday = index == 3;
              String dayLabel = isToday ? 'Today' : DateFormat('E').format(day);

              final dayEvents = events[DateTime(day.year, day.month, day.day)] ?? [];

              return DayPlannerCard(
                dayLabel: dayLabel,
                isToday: isToday,
                itemImagePaths: dayEvents.map((e) => e.thumbnailPath ?? e.imagePath).toList(),
                onAdd: () {
                  Navigator.pushNamed(context, AppRoutes.calendar, arguments: day);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}