// lib/services/quest_service.dart

import 'dart:convert';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestService {
  final SharedPreferences _prefs;

  static final List<Quest> _allQuests = [
    const Quest(
      id: 'first_steps',
      title: 'First Steps into Your Digital Closet',
      description: 'Add your first 3 tops and 3 bottoms (pants, skirts, or dresses) to start receiving personalized suggestions.',
      goal: QuestGoal(requiredCounts: {'Tops': 3, 'Bottomwear': 3}),
      status: QuestStatus.inProgress, 
    ),
  ];
  
  static const String _questProgressKey = 'quest_progress_key';

  QuestService(this._prefs);

  List<Quest> getCurrentQuests() {
    final questsJson = _prefs.getString(_questProgressKey);
    if (questsJson == null) {
      return _allQuests;
    }
    try {
      final List<dynamic> decodedList = json.decode(questsJson);
      final questsFromStorage = decodedList.map((data) {
        final questId = data['id'];
        final originalQuest = _allQuests.firstWhere((q) => q.id == questId);
        return originalQuest.copyWith(
          status: QuestStatus.values.byName(data['status']),
          progress: QuestProgress(
            currentCounts: Map<String, int>.from(data['progress']),
          ),
        );
      }).toList();
      return questsFromStorage;
    } catch (e) {
      logger.e("Error decoding quest progress, returning default.", error: e);
      return _allQuests;
    }
  }

  // SỬA LỖI: Thay đổi kiểu trả về từ Future<void> thành Future<Quest?>
  Future<Quest?> updateQuestProgress(ClothingItem newItem) async {
    final quests = getCurrentQuests();
    bool didUpdate = false;
    Quest? completedQuest; // Biến để lưu lại quest đã hoàn thành

    final activeQuests = quests.where((q) => q.status == QuestStatus.inProgress).toList();
    if (activeQuests.isEmpty) return null;

    for (var quest in activeQuests) {
      final mainCategory = newItem.category.split(' > ').first.trim();

      String? targetCategory;
      if (quest.goal.requiredCounts.containsKey(mainCategory)) {
        targetCategory = mainCategory;
      } else if (mainCategory == 'Bottoms' || mainCategory == 'Dresses/Jumpsuits') {
        targetCategory = 'Bottomwear';
      }

      if (targetCategory != null && quest.goal.requiredCounts.containsKey(targetCategory)) {
        final wasCompletedBefore = quest.isCompleted; // Kiểm tra trước khi cập nhật
        final newProgress = quest.progress.updateProgress(targetCategory);
        final questIndex = quests.indexWhere((q) => q.id == quest.id);
        quests[questIndex] = quest.copyWith(progress: newProgress);
        
        // Nếu trước đó chưa hoàn thành VÀ BÂY GIỜ đã hoàn thành
        if (!wasCompletedBefore && quests[questIndex].isCompleted) {
          quests[questIndex] = quests[questIndex].copyWith(status: QuestStatus.completed);
          logger.i("Quest '${quest.id}' completed!");
          completedQuest = quests[questIndex]; // Gán quest đã hoàn thành
        }
        didUpdate = true;
      }
    }

    if (didUpdate) {
      await _saveQuests(quests);
    }
    
    // Trả về quest đã hoàn thành (hoặc null nếu không có quest nào hoàn thành)
    return completedQuest;
  }

  Future<void> _saveQuests(List<Quest> quests) async {
    final List<Map<String, dynamic>> dataToSave = quests.map((q) => {
      'id': q.id,
      'status': q.status.name,
      'progress': q.progress.currentCounts,
    }).toList();
    await _prefs.setString(_questProgressKey, json.encode(dataToSave));
    logger.i("Saved new quest progress.");
  }

  Quest? getFirstActiveQuest() {
    final activeQuests = getCurrentQuests().where((q) => q.status == QuestStatus.inProgress);
    return activeQuests.isNotEmpty ? activeQuests.first : null;
  }
}