// lib/widgets/global_ui_scope.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/closets_page_notifier.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/widgets/quest_mascot.dart';
import 'package:mincloset/widgets/quest_mascot_image.dart';
import 'package:mincloset/models/notification_type.dart';

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
        final double initialDy = viewPadding.top + kToolbarHeight + 420.0;
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
        final l10n = AppLocalizations.of(context)!;

        // Hiển thị thông báo mascot cho mỗi guide hoàn thành
        ref
            .read(questMascotProvider.notifier)
            .showQuestCompletedNotification(l10n: l10n, screenWidth: screenWidth);

        // NẾU guide vừa hoàn thành là guide cuối cùng của chuỗi "beginner"
        if (next.id == 'first_log') {
          // Hiển thị dialog chúc mừng đặc biệt
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Congratulations!"),
              content: const Text("You've completed all the beginner guides and are now ready to master your digital closet!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Awesome!"),
                )
              ],
            ),
          );
        }

        ref.read(completedQuestProvider.notifier).state = null; // Reset lại
      }
    });

    // Xóa bỏ listener của `beginnerAchievementProvider`

    ref.listen<ClosetsPageState>(closetsPageProvider, (previous, next) {
      // ... (logic này không đổi)
      final notifier = ref.read(closetsPageProvider.notifier);
      final notificationService = ref.read(notificationServiceProvider);

      if (next.successMessage != null) {
        notificationService.showBanner(
          message: next.successMessage!,
          type: NotificationType.success,
        );
        notifier.clearMessages();
      }
      if (next.errorMessage != null) {
        notificationService.showBanner(message: next.errorMessage!);
        notifier.clearMessages();
      }
    });

    ref.listen<QuestHintState?>(questHintProvider, (previous, next) {
      // ... (logic này không đổi)
      if (next != null && next.routeName != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigatorKey = ref.read(nestedNavigatorKeyProvider);
            navigatorKey.currentState?.pushNamed(next.routeName!);
          }
        });
      }
    });

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

      await navigatorKey.currentState?.pushNamed(AppRoutes.guides);

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