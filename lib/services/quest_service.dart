// lib/services/quest_service.dart
import 'dart:convert';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestService {
  final SharedPreferences _prefs;

  // THAY ĐỔI 1: Cập nhật danh sách nhiệm vụ theo yêu cầu mới
  static final List<Quest> _allQuests = [
    // Quest 1: Yêu cầu 3 áo, 3 quần/váy. Trạng thái bắt đầu là inProgress.
    const Quest(
      id: 'first_steps',
      title: 'First Steps into Your Digital Closet',
      description: 'Add your first 3 tops and 3 bottoms (pants, skirts, etc.) to start receiving personalized suggestions.',
      goal: QuestGoal(requiredCounts: {
        QuestEvent.topAdded: 3,
        QuestEvent.bottomAdded: 3,
      }),
      status: QuestStatus.inProgress, 
    ),
    // Quest 2: Yêu cầu 1 gợi ý AI. Trạng thái bắt đầu là locked và có điều kiện.
    const Quest(
      id: 'first_suggestion',
      title: 'Your First AI-Powered Suggestion',
      description: 'Let\'s see what the AI has in store for you. Get your first outfit suggestion!',
      goal: QuestGoal(requiredCounts: {QuestEvent.suggestionReceived: 1}),
      status: QuestStatus.locked, // Bắt đầu ở trạng thái khóa
      prerequisiteQuestId: 'first_steps', // Điều kiện là phải xong quest 1
    ),
    // Quest 3: Tạo outfit đầu tiên
    const Quest(
      id: 'first_outfit',
      title: 'Your First Creation',
      description: 'Use the Outfit Builder to create and save your first custom outfit.',
      goal: QuestGoal(requiredCounts: {QuestEvent.outfitCreated: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_suggestion', // Điều kiện là phải xong quest 2
    ),
    // Quest 4: Tạo mới tủ đồ
    const Quest(
      id: 'organize_closet',
      title: 'Get Organized',
      description: 'Create a new closet to better organize your clothing items (e.g., for work, for sports).',
      goal: QuestGoal(requiredCounts: {QuestEvent.closetCreated: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'first_outfit', // Điều kiện là phải xong quest 3
    ),
    // Quest 5: Ghi nhận mặc đồ trong Nhật ký
    const Quest(
      id: 'first_log',
      title: 'Track Your Style Journey',
      description: 'Log an item or an outfit to your Journey to keep track of what you wear.',
      goal: QuestGoal(requiredCounts: {QuestEvent.logAdded: 1}),
      status: QuestStatus.locked,
      prerequisiteQuestId: 'organize_closet', // Điều kiện là phải xong quest 4
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

  // THAY ĐỔI 2: Nâng cấp logic để có thể "mở khóa" quest mới
  Future<List<Quest>> updateQuestProgress(QuestEvent event) async {
    final quests = getCurrentQuests();
    final List<Quest> newlyCompletedQuests = [];
    bool questsUnlocked = false;

    for (int i = 0; i < quests.length; i++) {
      if (quests[i].status == QuestStatus.inProgress && quests[i].goal.requiredCounts.containsKey(event)) {
          final wasCompletedBefore = quests[i].isCompleted;
          final newProgress = quests[i].progress.updateProgress(event);
          quests[i] = quests[i].copyWith(progress: newProgress);

          if (!wasCompletedBefore && quests[i].isCompleted) {
            quests[i] = quests[i].copyWith(status: QuestStatus.completed);
            newlyCompletedQuests.add(quests[i]);
            logger.i("Quest '${quests[i].id}' completed!");

            // Sau khi hoàn thành 1 quest, kiểm tra xem có quest nào được mở khóa không
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