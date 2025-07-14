// lib/services/quest_service.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/repositories/achievement_repository.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestService {
  final SharedPreferences _prefs;
  final AchievementRepository _achievementRepo;
  final Ref _ref;

  QuestService(this._prefs, this._achievementRepo, this._ref);

  // Danh sách quest giờ đây sẽ lưu các "khóa" thay vì văn bản tĩnh
  static final List<Quest> _allQuests = [
    const Quest(
      id: 'first_steps',
      titleKey: 'quest_firstSteps_title',
      descriptionKey: 'quest_firstSteps_description',
      goal: QuestGoal(requiredCounts: {
        QuestEvent.topAdded: 3,
        QuestEvent.bottomAdded: 3,
      }),
      status: QuestStatus.inProgress,
      hintKey: 'add_item_hint',
    ),
    const Quest(
      id: 'first_suggestion',
      titleKey: 'quest_firstSuggestion_title',
      descriptionKey: 'quest_firstSuggestion_description',
      goal: QuestGoal(requiredCounts: {QuestEvent.suggestionReceived: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_steps',
      hintKey: 'get_suggestion_hint',
    ),
    const Quest(
      id: 'first_outfit',
      titleKey: 'quest_firstOutfit_title',
      descriptionKey: 'quest_firstOutfit_description',
      goal: QuestGoal(requiredCounts: {QuestEvent.outfitCreated: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_suggestion',
      hintKey: 'create_outfit_hint',
    ),
    const Quest(
      id: 'organize_closet',
      titleKey: 'quest_organizeCloset_title',
      descriptionKey: 'quest_organizeCloset_description',
      goal: QuestGoal(requiredCounts: {QuestEvent.closetCreated: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_outfit',
      hintKey: 'create_closet_hint',
    ),
    const Quest(
      id: 'first_log',
      titleKey: 'quest_firstLog_title',
      descriptionKey: 'quest_firstLog_description',
      goal: QuestGoal(requiredCounts: {QuestEvent.logAdded: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'organize_closet',
      hintKey: 'log_wear_hint',
    ),
  ];
  
  static const String _questProgressKey = 'quest_progress_key';
  
  List<Quest> getCurrentQuests() {
    final questsJson = _prefs.getString(_questProgressKey);
    if (questsJson == null) {
      return _allQuests;
    }
    try {
      final List<dynamic> decodedList = json.decode(questsJson);
      final questsFromStorage = decodedList.map((data) {
        final questId = data['id'];
        final originalQuest = _allQuests.firstWhere((q) => q.id == questId, orElse: () => _allQuests.first);
        
        final Map<String, dynamic> progressMap = Map<String, dynamic>.from(data['progress']);
        final Map<QuestEvent, int> typedProgress = progressMap.map(
          (key, value) => MapEntry(QuestEvent.values.byName(key), value as int)
        );

        return originalQuest.copyWith(
          status: QuestStatus.values.byName(data['status']),
          progress: QuestProgress(currentCounts: typedProgress),
        );
      }).toList();
      return questsFromStorage;
    } catch (e) {
      logger.e("Error decoding quest progress, returning default.", error: e);
      return _allQuests;
    }
  }


  Future<List<Quest>> updateQuestProgress(QuestEvent event) async {
    final quests = getCurrentQuests();
    final List<Quest> newlyCompletedQuests = [];
    bool questsUnlocked = false;
    Quest? finalBeginnerQuest;

    for (int i = 0; i < quests.length; i++) {
      if (quests[i].status == QuestStatus.inProgress && quests[i].goal.requiredCounts.containsKey(event)) {
          final wasCompletedBefore = quests[i].isCompleted;
          final newProgress = quests[i].progress.updateProgress(event);
          quests[i] = quests[i].copyWith(progress: newProgress);

          if (!wasCompletedBefore && quests[i].isCompleted) {
            quests[i] = quests[i].copyWith(status: QuestStatus.completed);
            newlyCompletedQuests.add(quests[i]);
            logger.i("Quest '${quests[i].id}' completed!");

            if (quests[i].id == 'first_log') {
              finalBeginnerQuest = quests[i];
            }

            for (int j = 0; j < quests.length; j++) {
              if (quests[j].prerequisiteQuestId == quests[i].id && quests[j].status == QuestStatus.locked) {
                quests[j] = quests[j].copyWith(status: QuestStatus.inProgress);
                questsUnlocked = true;
                logger.i("Quest '${quests[j].id}' unlocked!");
              }
            }
          }
      }
    }

    if (finalBeginnerQuest != null) {
        final unlockedAchievement = await _achievementRepo.checkAndUnlockAchievements(quests);
        if (unlockedAchievement != null) {
          _ref.read(beginnerAchievementProvider.notifier).state = unlockedAchievement;
        }
    } 
    else if (newlyCompletedQuests.isNotEmpty) {
      _ref.read(completedQuestProvider.notifier).state = newlyCompletedQuests.first;
    }
    
    if (newlyCompletedQuests.isNotEmpty || questsUnlocked) {
      await _saveQuests(quests);
    }
    
    return newlyCompletedQuests;
  }
  
  Future<void> _saveQuests(List<Quest> quests) async {
    final List<Map<String, dynamic>> dataToSave = quests.map((q) {
      final Map<String, int> stringProgress = q.progress.currentCounts.map(
        (key, value) => MapEntry(key.name, value)
      );
      return {
        'id': q.id,
        'status': q.status.name,
        'progress': stringProgress,
      };
    }).toList();
    await _prefs.setString(_questProgressKey, json.encode(dataToSave));
    logger.i("Saved new quest progress.");
  }

  Quest? getFirstActiveQuest() {
    final activeQuests = getCurrentQuests().where((q) => q.status == QuestStatus.inProgress);
    return activeQuests.isNotEmpty ? activeQuests.first : null;
  }
}