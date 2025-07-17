// lib/screens/quests_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/models/achievement.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/achievements_page_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/screens/badge_detail_page.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/helpers/context_extensions.dart'; 
import 'package:mincloset/widgets/section_header.dart';

class QuestsPage extends ConsumerWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsPageProvider);
    final notifier = ref.read(achievementsPageProvider.notifier);

    return PageScaffold(
      appBar: AppBar(
        title: Text(context.l10n.quests_title),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.loadData,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  SectionHeader(title: context.l10n.quests_yourBadges_sectionHeader),
                  const SizedBox(height: 8),
                  _buildBadgesGrid(context, state),
                  const SizedBox(height: 24),
                  SectionHeader(title: context.l10n.quests_inProgress_sectionHeader),
                  if (state.inProgressQuests.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(context.l10n.quests_noActiveQuests_message),
                    ))
                  else
                    ...state.inProgressQuests.map((quest) {
                      return GestureDetector(
                        onTap: () {
                          if (quest.hintKey == 'log_wear_hint') {
                            ref.read(nestedNavigatorKeyProvider).currentState?.pushNamed(
                              AppRoutes.calendar,
                              arguments: const CalendarPageArgs(showHint: true),
                            );
                          } else if (quest.hintKey != null) {
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

  String _getEventLabel(QuestEvent event, AppLocalizations l10n) {
    switch (event) {
      case QuestEvent.topAdded: return l10n.quest_event_topAdded;
      case QuestEvent.bottomAdded: return l10n.quest_event_bottomAdded;
      case QuestEvent.suggestionReceived: return l10n.quest_event_suggestionReceived;
      case QuestEvent.outfitCreated: return l10n.quest_event_outfitCreated;
      case QuestEvent.closetCreated: return l10n.quest_event_closetCreated;
      case QuestEvent.logAdded: return l10n.quest_event_logAdded;
    }
  }

  // --- HÀM ĐỂ DỊCH KEY ---
  String _getQuestTranslation(String key, AppLocalizations l10n) {
    switch (key) {
      case 'quest_firstSteps_title': return l10n.quest_firstSteps_title;
      case 'quest_firstSteps_description': return l10n.quest_firstSteps_description;
      case 'quest_firstSuggestion_title': return l10n.quest_firstSuggestion_title;
      case 'quest_firstSuggestion_description': return l10n.quest_firstSuggestion_description;
      case 'quest_firstOutfit_title': return l10n.quest_firstOutfit_title;
      case 'quest_firstOutfit_description': return l10n.quest_firstOutfit_description;
      case 'quest_organizeCloset_title': return l10n.quest_organizeCloset_title;
      case 'quest_organizeCloset_description': return l10n.quest_organizeCloset_description;
      case 'quest_firstLog_title': return l10n.quest_firstLog_title;
      case 'quest_firstLog_description': return l10n.quest_firstLog_description;
      default: return key; // Trả về chính key nếu không tìm thấy
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
                // --- SỬA Ở ĐÂY ---
                Expanded(child: Text(_getQuestTranslation(quest.titleKey, context.l10n), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                if (quest.status == QuestStatus.inProgress && quest.hintKey != null)
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
              ],
            ),
            const SizedBox(height: 8),
            // --- SỬA Ở ĐÂY ---
            Text(_getQuestTranslation(quest.descriptionKey, context.l10n), style: theme.textTheme.bodyMedium),
            if (quest.status == QuestStatus.inProgress) ...[
              const SizedBox(height: 16),
              ...quest.goal.requiredCounts.keys.map((event) {
                final progressValue = (quest.progress.currentCounts[event] ?? 0) / (quest.goal.requiredCounts[event]!);
                return _ProgressIndicator(
                  label: '${_getEventLabel(event, context.l10n)}: ${quest.getProgressString(event)}',
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