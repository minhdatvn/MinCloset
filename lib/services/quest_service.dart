// lib/services/quest_service.dart

import 'dart:convert';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestService {
  final SharedPreferences _prefs;

  // Định nghĩa tất cả các nhiệm vụ có trong game tại đây
  static final List<Quest> _allQuests = [
    const Quest(
      id: 'first_steps',
      title: 'First Steps into Your Wardrobe',
      description: 'Add your first 3 tops and 3 bottoms/skirts to start receiving personalized suggestions.',
      goal: QuestGoal(requiredCounts: {'Tops': 3, 'Bottoms': 3, 'Dresses/Jumpsuits': 3}), // Mục tiêu kết hợp
      status: QuestStatus.inProgress, // Nhiệm vụ đầu tiên luôn bắt đầu
    ),
    // Thêm các nhiệm vụ khác ở đây trong tương lai
  ];

  // Khóa để lưu dữ liệu trong SharedPreferences
  static const String _questProgressKey = 'quest_progress_key';

  QuestService(this._prefs);

  // Lấy ra danh sách nhiệm vụ hiện tại của người dùng (đã có tiến trình)
  List<Quest> getCurrentQuests() {
    final questsJson = _prefs.getString(_questProgressKey);
    if (questsJson == null) {
      // Nếu chưa có dữ liệu, trả về danh sách nhiệm vụ mặc định
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

  // Hàm quan trọng: Cập nhật tiến trình khi người dùng thêm một món đồ mới
  Future<void> updateQuestProgress(ClothingItem newItem) async {
    final quests = getCurrentQuests();
    bool didUpdate = false;

    // Tìm các nhiệm vụ đang thực hiện (inProgress)
    final activeQuests = quests.where((q) => q.status == QuestStatus.inProgress).toList();
    if (activeQuests.isEmpty) return; // Không có nhiệm vụ nào cần cập nhật

    for (var quest in activeQuests) {
      final mainCategory = newItem.category.split(' > ').first.trim();
      
      // Kiểm tra xem danh mục của item mới có nằm trong mục tiêu của nhiệm vụ không
      if (quest.goal.requiredCounts.containsKey(mainCategory)) {
        // Cập nhật tiến trình
        final newProgress = quest.progress.updateProgress(mainCategory);
        
        // Cập nhật lại nhiệm vụ trong danh sách
        final questIndex = quests.indexWhere((q) => q.id == quest.id);
        quests[questIndex] = quest.copyWith(progress: newProgress);
        
        // Nếu nhiệm vụ hoàn thành, đổi trạng thái
        if (quests[questIndex].isCompleted) {
          quests[questIndex] = quests[questIndex].copyWith(status: QuestStatus.completed);
          logger.i("Quest '${quest.id}' completed!");
          // TODO: Hiển thị thông báo chúc mừng người dùng ở đây
        }
        didUpdate = true;
      }
    }

    if (didUpdate) {
      await _saveQuests(quests);
    }
  }

  // Lưu lại toàn bộ danh sách nhiệm vụ vào SharedPreferences
  Future<void> _saveQuests(List<Quest> quests) async {
    final List<Map<String, dynamic>> dataToSave = quests.map((q) => {
      'id': q.id,
      'status': q.status.name,
      'progress': q.progress.currentCounts,
    }).toList();
    await _prefs.setString(_questProgressKey, json.encode(dataToSave));
    logger.i("Saved new quest progress.");
  }

  // Hàm để lấy ra nhiệm vụ đang hoạt động đầu tiên để hiển thị trên FAB
  Quest? getFirstActiveQuest() {
    final activeQuests = getCurrentQuests().where((q) => q.status == QuestStatus.inProgress);
    return activeQuests.isNotEmpty ? activeQuests.first : null;
  }
}