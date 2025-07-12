// lib/screens/quests_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/achievement.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/achievements_page_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/screens/badge_detail_page.dart';
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
        title: const Text('Achievements'),
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
                  _buildBadgesGrid(context, state),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'In Progress'),
                  if (state.inProgressQuests.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No active quests. Great job!'),
                    ))
                  else
                    ...state.inProgressQuests.map((quest) {
                      // Bọc QuestCard trong GestureDetector
                      return GestureDetector(
                        onTap: () {
                          // --- BẮT ĐẦU SỬA ĐỔI ---
                          // Nếu quest này có hintKey, chúng ta sẽ xử lý điều hướng tại đây
                          if (quest.hintKey == 'log_wear_hint') {
                            // Lấy nested navigator key và điều hướng với argument
                            ref.read(nestedNavigatorKeyProvider).currentState?.pushNamed(
                              AppRoutes.calendar,
                              arguments: const CalendarPageArgs(showHint: true), // Truyền tín hiệu trực tiếp
                            );
                          } else if (quest.hintKey != null) {
                            // Xử lý cho các hint khác trên MainScreen nếu có
                            ref.read(questHintProvider.notifier).triggerHint(quest.hintKey!);
                            Navigator.of(context).pop();
                          }
                        },
                        child: QuestCard(quest: quest),
                      );
                    }),
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

  Widget _buildBadgesGrid(BuildContext context, AchievementsPageState state) {
    if (state.allBadges.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.allBadges.length,
      itemBuilder: (context, index) {
        final badge = state.allBadges[index];
        final isUnlocked = state.unlockedBadgeIds.contains(badge.id);

        return GestureDetector(
          onTap: () {
            final achievement = state.allAchievements.firstWhere(
              (a) => a.badgeId == badge.id,
              orElse: () => const Achievement(id: '', name: '', description: '', badgeId: '', requiredQuestIds: []),
            );

            // Quan trọng: Vì huy hiệu chưa mở khóa nên danh sách quest hoàn thành sẽ rỗng
            final questsForBadge = state.completedQuestsByAchievement[achievement.id] ?? [];

            Navigator.pushNamed(
              context, 
              AppRoutes.badgeDetail, 
              arguments: BadgeDetailPageArgs(badge: badge, quests: questsForBadge, isUnlocked: isUnlocked)
            );
          },
          child: Tooltip(
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
          ),
        );
      },
    );
  }
}

class QuestCard extends StatelessWidget {
  final Quest quest;
  const QuestCard({super.key, required this.quest});

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
    final iconData = isCompleted ? Icons.check_circle : (quest.hintKey != null ? Icons.lightbulb_outline : Icons.stream);
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
                if (quest.status == QuestStatus.inProgress && quest.hintKey != null)
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
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