// lib/widgets/global_ui_scope.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/dialog_helpers.dart';
import 'package:mincloset/models/achievement.dart'; // Thêm import này
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/quest_mascot_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/widgets/achievement_unlocked_dialog.dart';
import 'package:mincloset/widgets/quest_mascot.dart';

class GlobalUiScope extends ConsumerWidget {
  final Widget child;
  const GlobalUiScope({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- LẮNG NGHE CÁC SỰ KIỆN TOÀN CỤC ---
    // (Phần listener không thay đổi)
    ref.listen<Quest?>(completedQuestProvider, (previous, next) {
      if (next != null) {
        final screenWidth = MediaQuery.of(context).size.width;
        ref.read(questMascotProvider.notifier).showQuestCompletedNotification(next.title, screenWidth);
        ref.read(completedQuestProvider.notifier).state = null;
      }
    });

    ref.listen<Achievement?>(unlockedAchievementProvider, (previous, next) {
      if (next != null) {
        final badge = ref.read(achievementRepositoryProvider).getAllBadges()
            .firstWhere((b) => b.id == next.badgeId);
            
        showAnimatedDialog(
          context,
          barrierDismissible: false,
          builder: (_) => AchievementUnlockedDialog(badge: badge),
        );
        ref.read(unlockedAchievementProvider.notifier).state = null;
      }
    });

    final mascotState = ref.watch(questMascotProvider);

    // THÊM LẠI LOGIC KHỞI TẠO VỊ TRÍ
    // Chỉ thực hiện một lần khi position chưa được thiết lập
    if (mascotState.position == null) {
      // Dùng addPostFrameCallback để đảm bảo context đã sẵn sàng
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Kiểm tra lại `mounted` để đảm bảo an toàn
        if (context.mounted) {
          final size = MediaQuery.of(context).size;
          const mascotWidth = 80.0;
          const rightPadding = 16.0;
          final dx = size.width - mascotWidth - rightPadding;
          final dy = 450.0; // Vị trí Y ban đầu
          ref.read(questMascotProvider.notifier).updatePosition(Offset(dx, dy));
        }
      });
    }
    
    // --- XÂY DỰNG GIAO DIỆN ---
    return Stack(
      children: [
        child,
        if (mascotState.isVisible && mascotState.position != null)
          const QuestMascot(),
      ],
    );
  }
}