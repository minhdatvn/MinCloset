// lib/widgets/global_ui_scope.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/routing/app_routes.dart'; // Thêm import này
import 'package:mincloset/widgets/quest_mascot.dart';
import 'package:mincloset/widgets/quest_mascot_image.dart';
import 'package:mincloset/providers/service_providers.dart';

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
    ref.listen<Quest?>(completedQuestProvider, (previous, next) {
      if (next != null) {
        final screenWidth = MediaQuery.of(context).size.width;
        ref
            .read(questMascotProvider.notifier)
            .showQuestCompletedNotification(next.title, screenWidth);
        ref.read(completedQuestProvider.notifier).state = null;
      }
    });

    final mascotState = ref.watch(questMascotProvider);
    final mascotNotifier = ref.read(questMascotProvider.notifier);

    if (!mascotState.isVisible || mascotState.position == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: mascotState.position!.dx,
      top: mascotState.position!.dy,
      // THAY ĐỔI 1: BỌC DRAGGABLE BẰNG GESTUREDETECTOR
      child: GestureDetector(
        onTap: () {
          // Chuyển logic điều hướng ra đây
          Navigator.of(context).pushNamed(AppRoutes.quests);
          mascotNotifier.hideCurrentNotification();
        },
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
            onTap: () {
              // THAY ĐỔI CỐT LÕI NẰM Ở ĐÂY
              // 1. Đọc key từ provider
              final navigatorKey = ref.read(nestedNavigatorKeyProvider);

              // 2. Sử dụng key để điều hướng, đảm bảo gọi đúng Navigator
              navigatorKey.currentState?.pushNamed(AppRoutes.quests);

              // 3. Logic còn lại giữ nguyên
              mascotNotifier.hideCurrentNotification();
            },
          ),
        ),
      ),
    );
  }
}