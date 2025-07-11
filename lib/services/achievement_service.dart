// lib/services/achievement_service.dart
import 'package:mincloset/models/achievement.dart';
import 'package:mincloset/models/badge.dart';
import 'package:mincloset/models/quest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementService {
  final SharedPreferences _prefs;

  AchievementService(this._prefs);

  static const String _unlockedAchievementKey = 'unlocked_achievement_ids';

  // --- CƠ SỞ DỮ LIỆU CỦA HUY HIỆU VÀ THÀNH TÍCH ---

  // Định nghĩa tất cả các huy hiệu có trong ứng dụng
  final List<Badge> _allBadges = [
    const Badge(
      id: 'badge_beginner',
      name: 'Fashion Beginner',
      description: 'You\'ve mastered the basics of MinCloset and started your style journey!',
      imagePath: 'assets/images/badges/badge_beginner.webp',
    ),
    // Thêm các huy hiệu khác ở đây trong tương lai
  ];

  // Định nghĩa tất cả các thành tích (nhóm nhiệm vụ)
  final List<Achievement> _allAchievements = [
    const Achievement(
      id: 'achieve_beginner_quests',
      name: 'Beginner Quests Completed',
      description: 'Complete all the introductory quests.',
      badgeId: 'badge_beginner',
      requiredQuestIds: [ // Nhóm 5 quest đầu tiên lại với nhau
        'first_steps',
        'first_suggestion',
        'first_outfit',
        'organize_closet',
        'first_log',
      ],
    ),
    // Thêm các thành tích khác ở đây trong tương lai
  ];

  // --- CÁC HÀM LOGIC ---

  List<Badge> getAllBadges() => _allBadges;
  List<Achievement> getAllAchievements() => _allAchievements;
  
  Set<String> getUnlockedAchievementIds() {
    return _prefs.getStringList(_unlockedAchievementKey)?.toSet() ?? {};
  }

  // Hàm kiểm tra và mở khóa thành tích
  // Nó sẽ trả về thành tích vừa được mở khóa (nếu có)
  Future<Achievement?> checkAndUnlockAchievements(List<Quest> allQuests) async {
    final unlockedIds = getUnlockedAchievementIds();
    final completedQuestIds = allQuests
        .where((q) => q.status == QuestStatus.completed)
        .map((q) => q.id)
        .toSet();

    Achievement? newlyUnlockedAchievement;

    // Lặp qua tất cả các thành tích chưa được mở khóa
    for (final achievement in _allAchievements) {
      if (!unlockedIds.contains(achievement.id)) {
        // Kiểm tra xem người dùng đã hoàn thành tất cả các quest yêu cầu chưa
        if (completedQuestIds.containsAll(achievement.requiredQuestIds)) {
          // Mở khóa thành tích!
          unlockedIds.add(achievement.id);
          newlyUnlockedAchievement = achievement;
          break; // Giả sử mỗi lần chỉ mở khóa được 1 thành tích
        }
      }
    }

    if (newlyUnlockedAchievement != null) {
      await _prefs.setStringList(_unlockedAchievementKey, unlockedIds.toList());
    }
    
    return newlyUnlockedAchievement;
  }
}