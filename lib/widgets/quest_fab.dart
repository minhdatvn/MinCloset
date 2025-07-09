// lib/widgets/quest_fab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/quests_page_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';

class QuestFab extends ConsumerWidget {
  const QuestFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe provider chỉ chứa nhiệm vụ đang hoạt động
    final activeQuest = ref.watch(activeQuestProvider);

    // Nếu không có nhiệm vụ nào đang hoạt động, không hiển thị gì cả
    if (activeQuest == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    // Xây dựng chuỗi tiến trình chính
    // Ví dụ: "Tops: 1/3, Bottoms: 2/3"
    final progressString = activeQuest.goal.requiredCounts.keys
        .map((category) => '$category: ${activeQuest.getProgressString(category)}')
        .join(', ');

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.quests);
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.flag_outlined),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeQuest.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            progressString,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}