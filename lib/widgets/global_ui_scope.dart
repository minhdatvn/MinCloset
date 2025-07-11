// lib/widgets/global_ui_scope.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/achievement.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/achievement_unlocked_dialog.dart'; // <<< THÊM IMPORT NÀY
import 'package:mincloset/widgets/quest_mascot.dart';
import 'package:mincloset/widgets/quest_mascot_image.dart';

class GlobalUiScope extends ConsumerStatefulWidget {
  const GlobalUiScope({super.key});

  @override
  ConsumerState<GlobalUiScope> createState() => _GlobalUiScopeState();
}

class _GlobalUiScopeState extends ConsumerState<GlobalUiScope> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(questMascotProvider).position == null) {
        final size = MediaQuery.of(context).size;
        final viewPadding = MediaQuery.of(context).viewPadding;
        const mascotWidth = 80.0;
        final double initialDx = size.width - mascotWidth - 16.0;
        final double initialDy = viewPadding.top + kToolbarHeight + 20.0;
        ref
            .read(questMascotProvider.notifier)
            .updatePosition(Offset(initialDx, initialDy));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự kiện hoàn thành nhiệm vụ ĐƠN LẺ
    ref.listen<Quest?>(completedQuestProvider, (previous, next) {
      if (next != null) {
        final screenWidth = MediaQuery.of(context).size.width;
        ref
            .read(questMascotProvider.notifier)
            .showQuestCompletedNotification(next.title, screenWidth);
        ref.read(completedQuestProvider.notifier).state = null; // Reset lại
      }
    });

    // <<< BẮT ĐẦU SỬA ĐỔI: Lắng nghe sự kiện hoàn thành NHÓM NHIỆM VỤ >>>
    ref.listen<Achievement?>(beginnerAchievementProvider, (previous, next) {
      if (next != null) {
        // Tìm huy hiệu tương ứng với thành tích
        final badge = ref.read(achievementRepositoryProvider).getBadgeById(next.badgeId);
        if (badge != null) {
          // Hiển thị dialog chúc mừng hoành tráng
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AchievementUnlockedDialog(badge: badge),
          );
        }
        // Reset provider để không hiển thị lại
        ref.read(beginnerAchievementProvider.notifier).state = null;
      }
    });
    // <<< KẾT THÚC SỬA ĐỔI >>>

    final mascotState = ref.watch(questMascotProvider);
    final mascotNotifier = ref.read(questMascotProvider.notifier);
    final isQuestsPageActive = ref.watch(isQuestsPageActiveProvider);

    if (!mascotState.isVisible || mascotState.position == null) {
      return const SizedBox.shrink();
    }

    Future<void> handleTap() async {
      if (isQuestsPageActive) return;

      final questsPageNotifier = ref.read(isQuestsPageActiveProvider.notifier);
      final navigatorKey = ref.read(nestedNavigatorKeyProvider);
      
      questsPageNotifier.state = true;
      mascotNotifier.hideCurrentNotification();

      await navigatorKey.currentState?.pushNamed(AppRoutes.quests);

      // Đặt lại cờ sau khi quay về
      if (mounted) {
        questsPageNotifier.state = false;
      }
    }

    return Positioned(
      left: mascotState.position!.dx,
      top: mascotState.position!.dy,
      child: GestureDetector(
        onTap: handleTap,
        child: Draggable(
          feedback: const QuestMascotImage(),
          childWhenDragging: const SizedBox.shrink(),
          dragAnchorStrategy: (draggable, context, position) {
            return mascotState.originalPosition == null
                ? const Offset(40, 40)
                : Offset.zero;
          },
          onDragEnd: (details) {
            if (mascotState.originalPosition == null) {
              final size = MediaQuery.of(context).size;
              const mascotWidth = 80.0;
              double newDx = details.offset.dx;

              if ((newDx + mascotWidth / 2) < size.width / 2) {
                newDx = 16.0;
              } else {
                newDx = size.width - mascotWidth - 16.0;
              }
              mascotNotifier.updatePosition(Offset(newDx, details.offset.dy));
            }
          },
          child: QuestMascot(
            onTap: handleTap,
          ),
        ),
      ),
    );
  }
}