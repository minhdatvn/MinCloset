// lib/screens/badge_detail_page.dart
import 'package:flutter/material.dart';
import 'package:mincloset/models/badge.dart' as model;
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/screens/quests_page.dart'; // Sử dụng lại _QuestCard
import 'package:mincloset/widgets/page_scaffold.dart';

// Lớp để truyền tham số
class BadgeDetailPageArgs {
  final model.Badge badge;
  final List<Quest> quests;
  final bool isUnlocked;

  const BadgeDetailPageArgs({required this.badge, required this.quests, required this.isUnlocked,});
}

class BadgeDetailPage extends StatelessWidget {
  final BadgeDetailPageArgs args;
  const BadgeDetailPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageScaffold(
      appBar: AppBar(
        title: Text(args.badge.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Phần thông tin Badge
          Column(
            children: [
              Opacity( // <-- Bọc bằng Opacity
                opacity: args.isUnlocked ? 1.0 : 0.3, // <-- Thêm logic opacity
                child: Image.asset(
                  args.badge.imagePath,
                  width: 100,
                  height: 100,
                  errorBuilder: (ctx, err, st) => const Icon(Icons.shield, size: 100),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                args.badge.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                args.badge.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const Divider(height: 32),
          // Tiêu đề cho phần quest
          Text(
            'Completed Quests',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Danh sách các quest đã hoàn thành
          if (args.quests.isEmpty)
            const Center(child: Text('No quests found for this badge.'))
          else
            ...args.quests.map((quest) => QuestCard(quest: quest)),
        ],
      ),
    );
  }
}