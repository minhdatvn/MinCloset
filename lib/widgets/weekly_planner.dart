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
      if (_scrollController.hasClients && mounted) {
        
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Chiều rộng của một thẻ bao gồm cả lề hai bên (4px + 110px + 4px)
        const cardTotalWidth = 118.0; 
        
        // Vị trí tâm của thẻ "Today" (index 3) so với lề trái của ListView
        // (Vị trí bắt đầu của thẻ thứ 4) + (một nửa chiều rộng của thẻ)
        final todayCardCenterInList = (3 * cardTotalWidth) + (_cardWidth / 2);

        // Tâm của màn hình
        final screenCenter = screenWidth / 2;

        // Vị trí cuộn cần thiết để đưa tâm thẻ vào tâm màn hình
        final targetOffset = todayCardCenterInList - screenCenter;
        
        _scrollController.jumpTo(targetOffset < 0 ? 0 : targetOffset);
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: SectionHeader(
            title: "Week's Journal",
            seeAllText: 'View more',
            onSeeAll: () {
              Navigator.pushNamed(context, AppRoutes.calendar);
            },
          ),
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
                date: day,
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