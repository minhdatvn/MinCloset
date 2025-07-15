// lib/widgets/weekly_planner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/notifiers/calendar_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/day_planner_card.dart';
import 'package:mincloset/widgets/section_header.dart';

class WeeklyPlanner extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  const WeeklyPlanner({super.key, required this.l10n});

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
        
        // Chiều rộng của một thẻ là 110.0, được định nghĩa bởi _cardWidth.
        // Vị trí của thẻ "Today" (index = 3) là 3 * _cardWidth.
        // Tâm của nó sẽ là vị trí bắt đầu + một nửa chiều rộng.
        final todayCardCenterInList = (3 * _cardWidth) + (_cardWidth / 2);

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

  String _getVietnameseDayLabel(DateTime day) {
    // weekday trả về giá trị từ 1 (Thứ 2) đến 7 (Chủ nhật)
    switch (day.weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'Chủ nhật';
      default:
        return '';
    }
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
            title: widget.l10n.home_weeklyJournalTitle,
            seeAllText: widget.l10n.home_weeklyJournalViewMore,
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
              String dayLabel;
              if (isToday) {
                dayLabel = widget.l10n.common_today;
              } else if (widget.l10n.localeName == 'vi') {
                // Nếu là tiếng Việt, gọi hàm helper mới
                dayLabel = _getVietnameseDayLabel(day);
              } else {
                // Nếu là ngôn ngữ khác, dùng DateFormat như cũ
                dayLabel = DateFormat('E', widget.l10n.localeName).format(day);
              }

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