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

    // THAY ĐỔI 1: Chỉ lọc ra các quest đang và đã hoàn thành. Bỏ qua quest bị khóa.
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
          ],

          // THAY ĐỔI 2: Xóa bỏ hoàn toàn khối code hiển thị các quest bị khóa
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

class _QuestCard extends StatelessWidget {
  final Quest quest;
  const _QuestCard({required this.quest});

  String _getEventLabel(QuestEvent event) {
    switch (event) {
      case QuestEvent.topAdded:
        return 'Tops Added';
      case QuestEvent.bottomAdded:
        return 'Bottoms Added';
      case QuestEvent.suggestionReceived:
        return 'AI Suggestion';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = quest.status == QuestStatus.completed;

    final Color cardColor = isCompleted ? Colors.green.withAlpha(20) : theme.colorScheme.surfaceContainerHighest;
    final Color borderColor = isCompleted ? Colors.green : Colors.grey.shade300;
    final IconData leadingIcon = isCompleted ? Icons.check_circle : Icons.stream;
    final Color iconColor = isCompleted ? Colors.green : theme.colorScheme.primary;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(leadingIcon, color: iconColor),
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
            
            if (quest.status == QuestStatus.inProgress) ...[
              const SizedBox(height: 16),
              ...quest.goal.requiredCounts.keys.map((event) {
                final progressValue = (quest.progress.currentCounts[event] ?? 0) / (quest.goal.requiredCounts[event]!);
                return _ProgressIndicator(
                  label: '${_getEventLabel(event)}: ${quest.getProgressString(event)}',
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