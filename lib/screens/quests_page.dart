// lib/screens/quests_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/badge.dart' as model;
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/achievements_page_notifier.dart';
import 'package:mincloset/widgets/page_scaffold.dart';

// Trả về dạng ConsumerWidget đơn giản
class QuestsPage extends ConsumerWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsPageProvider);
    final notifier = ref.read(achievementsPageProvider.notifier);

    return PageScaffold(
      appBar: AppBar(
        title: const Text('Quests & Achievements'),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.loadData,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle(context, 'Your Badges'),
                  const SizedBox(height: 8),
                  _buildBadgesGrid(context, state.allBadges, state.unlockedBadgeIds),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'In Progress'),
                  if (state.inProgressQuests.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No active quests. Great job!'),
                    ))
                  else
                    ...state.inProgressQuests.map((quest) => _QuestCard(quest: quest)),
                  
                  if (state.completedQuests.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Completed'),
                    ...state.completedQuests.map((quest) => _QuestCard(quest: quest)),
                  ],
                ],
              ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, List<model.Badge> allBadges, Set<String> unlockedIds) {
    if (allBadges.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final model.Badge badge = allBadges[index];
        final isUnlocked = unlockedIds.contains(badge.id);

        return Tooltip(
          message: '${badge.name}\n${badge.description}',
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Image.asset(
              badge.imagePath,
              errorBuilder: (ctx, err, stack) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.shield_outlined, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  const _QuestCard({required this.quest});

  String _getEventLabel(QuestEvent event) {
    switch (event) {
      case QuestEvent.topAdded: return 'Tops Added';
      case QuestEvent.bottomAdded: return 'Bottoms Added';
      case QuestEvent.suggestionReceived: return 'AI Suggestion';
      case QuestEvent.outfitCreated: return 'Outfit Created';
      case QuestEvent.closetCreated: return 'New Closet';
      case QuestEvent.logAdded: return 'Item/Outfit Logged';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = quest.status == QuestStatus.completed;
    final cardColor = isCompleted ? Colors.green.withAlpha(20) : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isCompleted ? Colors.green : Colors.grey.shade300;
    final iconData = isCompleted ? Icons.check_circle : Icons.stream;
    final iconColor = isCompleted ? Colors.green : theme.colorScheme.primary;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor, width: 1)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor),
                const SizedBox(width: 8),
                Expanded(child: Text(quest.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
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
          LinearProgressIndicator(value: value, borderRadius: BorderRadius.circular(4), minHeight: 6),
        ],
      ),
    );
  }
}