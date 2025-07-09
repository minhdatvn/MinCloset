// lib/services/quest_service.dart

import 'dart:convert';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestService {
  final SharedPreferences _prefs;

  // *** THAY ĐỔI 1: Cập nhật định nghĩa nhiệm vụ ***
  // Sửa lại tiêu đề và mô tả.
  // Gộp 'Bottoms' và 'Dresses/Jumpsuits' thành một mục tiêu chung là 'Bottomwear'.
  static final List<Quest> _allQuests = [
    const Quest(
      id: 'first_steps',
      title: 'First Steps into Your Digital Closet',
      description: 'Add your first 3 tops and 3 bottoms (pants, skirts, or dresses) to start receiving personalized suggestions.',
      goal: QuestGoal(requiredCounts: {'Tops': 3, 'Bottomwear': 3}), // Mục tiêu mới
      status: QuestStatus.inProgress, 
    ),
  ];
  
  static const String _questProgressKey = 'quest_progress_key';

  QuestService(this._prefs);

  List<Quest> getCurrentQuests() {
    // ... (Hàm này không thay đổi)
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

  Future<void> updateQuestProgress(ClothingItem newItem) async {
    final quests = getCurrentQuests();
    bool didUpdate = false;
    final activeQuests = quests.where((q) => q.status == QuestStatus.inProgress).toList();
    if (activeQuests.isEmpty) return;

    for (var quest in activeQuests) {
      final mainCategory = newItem.category.split(' > ').first.trim();

      // *** THAY ĐỔI 2: Cập nhật logic xử lý tiến trình ***
      // Ánh xạ các danh mục thực tế vào danh mục mục tiêu của nhiệm vụ.
      String? targetCategory;
      if (quest.goal.requiredCounts.containsKey(mainCategory)) {
        targetCategory = mainCategory; // Xử lý trường hợp khớp trực tiếp (ví dụ: 'Tops')
      } else if (mainCategory == 'Bottoms' || mainCategory == 'Dresses/Jumpsuits') {
        targetCategory = 'Bottomwear'; // Gộp vào mục tiêu 'Bottomwear'
      }

      if (targetCategory != null && quest.goal.requiredCounts.containsKey(targetCategory)) {
        final newProgress = quest.progress.updateProgress(targetCategory);
        final questIndex = quests.indexWhere((q) => q.id == quest.id);
        quests[questIndex] = quest.copyWith(progress: newProgress);
        
        if (quests[questIndex].isCompleted) {
          quests[questIndex] = quests[questIndex].copyWith(status: QuestStatus.completed);
          logger.i("Quest '${quest.id}' completed!");
        }
        didUpdate = true;
      }
    }

    if (didUpdate) {
      await _saveQuests(quests);
    }
  }

  Future<void> _saveQuests(List<Quest> quests) async {
    // ... (Hàm này không thay đổi)
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