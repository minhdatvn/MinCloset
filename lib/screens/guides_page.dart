// lib/screens/guides_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/l10n/app_localizations.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/guides_page_notifier.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/providers/ui_providers.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/routing/route_generator.dart';
import 'package:mincloset/widgets/page_scaffold.dart';
import 'package:mincloset/helpers/context_extensions.dart'; 
import 'package:mincloset/widgets/section_header.dart';

// Đổi tên class
class GuidesPage extends ConsumerWidget {
  const GuidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng provider mới
    final state = ref.watch(guidesPageProvider);
    final notifier = ref.read(guidesPageProvider.notifier);

    return PageScaffold(
      appBar: AppBar(
        // Đổi tiêu đề
        title: const Text("FAQ & Guides"), 
      ),
      body: RefreshIndicator(
        onRefresh: notifier.loadGuides,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Phần Guides đang thực hiện
                  SectionHeader(title: "Beginner Guides"),
                  if (state.inProgressGuides.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      // Thay đổi văn bản
                      child: const Text("You've completed all guides!"),
                    ))
                  else
                    ...state.inProgressGuides.map((guide) {
                      return GestureDetector(
                        onTap: () {
                          if (guide.hintKey == 'log_wear_hint') {
                            ref.read(nestedNavigatorKeyProvider).currentState?.pushNamed(
                              AppRoutes.calendar,
                              arguments: const CalendarPageArgs(showHint: true),
                            );
                          } else if (guide.hintKey != null) {
                            ref.read(questHintProvider.notifier).triggerHint(guide.hintKey!);
                            Navigator.of(context).pop();
                          }
                        },
                        // Đổi tên QuestCard thành GuideCard
                        child: GuideCard(guide: guide),
                      );
                    }),

                  const Divider(height: 32),

                  // Phần Guides đã hoàn thành
                  SectionHeader(title: "Completed Guides"),
                  if (state.completedGuides.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text("No guides completed yet."),
                    ))
                  else
                     ...state.completedGuides.map((guide) => GuideCard(guide: guide)),

                  const Divider(height: 32),

                  // Phần FAQ mới
                  SectionHeader(title: "Frequently Asked Questions (FAQ)"),
                  const SizedBox(height: 8),
                  const _FaqItem(
                    question: "How does AI suggestion work?",
                    answer: "The app sends anonymized information about your closet items and local weather to a powerful AI (Google's Gemini) to generate a personalized and reasoned outfit suggestion.",
                  ),
                  const _FaqItem(
                    question: "Is my data private?",
                    answer: "Yes. All your data, including photos, is stored locally on your device. If you choose to back up, your data is stored securely in your own private cloud space on Firebase, protected by Google's security standards.",
                  ),
                   const _FaqItem(
                    question: "Why do I need to log in for backup?",
                    answer: "Logging in creates a secure link between you and your data on the cloud. This ensures that only you can access, back up, or restore your closet information.",
                  ),
                ],
              ),
      ),
    );
  }
}

// Đổi tên QuestCard thành GuideCard
class GuideCard extends StatelessWidget {
  final Quest guide;
  const GuideCard({super.key, required this.guide});

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
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = guide.status == QuestStatus.completed;
    final cardColor = isCompleted ? Colors.green.withAlpha(20) : theme.colorScheme.surfaceContainerHighest;
    final borderColor = isCompleted ? Colors.green : Colors.grey.shade300;
    final iconData = isCompleted ? Icons.check_circle : (guide.hintKey != null ? Icons.lightbulb_outline : Icons.stream);
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
                Expanded(child: Text(_getQuestTranslation(guide.titleKey, context.l10n), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                if (guide.status == QuestStatus.inProgress && guide.hintKey != null)
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
              ],
            ),
            const SizedBox(height: 8),
            Text(_getQuestTranslation(guide.descriptionKey, context.l10n), style: theme.textTheme.bodyMedium),
            if (guide.status == QuestStatus.inProgress) ...[
              const SizedBox(height: 16),
              ...guide.goal.requiredCounts.keys.map((event) {
                final progressValue = (guide.progress.currentCounts[event] ?? 0) / (guide.goal.requiredCounts[event]!);
                return _ProgressIndicator(
                  label: '${_getEventLabel(event, context.l10n)}: ${guide.getProgressString(event)}',
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

// Widget helper cho thanh tiến trình (không đổi)
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

// Widget helper mới cho các câu hỏi FAQ
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}