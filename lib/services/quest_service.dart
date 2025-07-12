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

  // <<< THÊM hintKey VÀO ĐỊNH NGHĨA QUESTS >>>
  static final List<Quest> _allQuests = [
    const Quest(
      id: 'first_steps',
      title: 'First Steps into Your Digital Closet',
      description: 'Add your first 3 tops and 3 bottoms (pants, skirts, etc.) to start receiving personalized suggestions.',
      goal: QuestGoal(requiredCounts: {
        QuestEvent.topAdded: 3,
        QuestEvent.bottomAdded: 3,
      }),
      status: QuestStatus.inProgress,
      hintKey: 'add_item_hint', // Gợi ý chỉ vào nút "Add Item"
    ),
    const Quest(
      id: 'first_suggestion',
      title: 'Your First AI-Powered Suggestion',
      description: 'Let\'s see what the AI has in store for you. Get your first outfit suggestion!',
      goal: QuestGoal(requiredCounts: {QuestEvent.suggestionReceived: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_steps',
      hintKey: 'get_suggestion_hint', // Gợi ý chỉ vào nút "Get Suggestion"
    ),
    const Quest(
      id: 'first_outfit',
      title: 'Your First Creation',
      description: 'Use the Outfit Builder to create and save your first custom outfit.',
      goal: QuestGoal(requiredCounts: {QuestEvent.outfitCreated: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_suggestion',
      hintKey: 'create_outfit_hint', // Gợi ý chỉ vào nút "Create Outfits"
    ),
    const Quest(
      id: 'organize_closet',
      title: 'Get Organized',
      description: 'Create a new closet to better organize your clothing items (e.g., for work, for sports).',
      goal: QuestGoal(requiredCounts: {QuestEvent.closetCreated: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_outfit',
      hintKey: 'create_closet_hint', // Gợi ý chỉ vào nút "Create New Closet"
    ),
    const Quest(
      id: 'first_log',
      title: 'Track Your Style Journey',
      description: 'Log an item or an outfit to your Journey to keep track of what you wear.',
      goal: QuestGoal(requiredCounts: {QuestEvent.logAdded: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'organize_closet',
      hintKey: 'log_wear_hint', // Gợi ý chỉ vào nút "Add" trên trang Lịch
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