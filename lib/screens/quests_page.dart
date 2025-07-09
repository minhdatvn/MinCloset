// lib/screens/quests_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/quests_page_notifier.dart';

class QuestsPage extends ConsumerWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questsPageProvider);

    final inProgressQuests = quests.where((q) => q.status == QuestStatus.inProgress).toList();
    final completedQuests = quests.where((q) => q.status == QuestStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Quests'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'In Progress'),
          if (inProgressQuests.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text('No active quests. Great job!'),
            ))
          else
            ...inProgressQuests.map((quest) => _QuestCard(quest: quest)),
          
          if (completedQuests.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Completed'),
            ...completedQuests.map((quest) => _QuestCard(quest: quest)),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Widget cho mỗi thẻ nhiệm vụ
class _QuestCard extends StatelessWidget {
  final Quest quest;
  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = quest.status == QuestStatus.completed;

    return Card(
      elevation: 0,
      color: isCompleted ? Colors.green.withAlpha(20) : theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green : Colors.grey.shade300,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.stream,
                  color: isCompleted ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quest.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(quest.description, style: theme.textTheme.bodyMedium),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              // Hiển thị các thanh tiến trình cho từng mục tiêu
              ...quest.goal.requiredCounts.keys.map((category) {
                final required = quest.goal.requiredCounts[category]!;
                final current = quest.progress.currentCounts[category] ?? 0;
                final progressValue = required > 0 ? (current / required) : 1.0;

                return _ProgressIndicator(
                  label: '$category: ${quest.getProgressString(category)}',
                  value: progressValue,
                );
              }),
            ]
          ],
        ),
      ),
    );
  }
}

// Widget cho thanh tiến trình
class _ProgressIndicator extends StatelessWidget {
  final String label;
  final double value;
  const _ProgressIndicator({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}