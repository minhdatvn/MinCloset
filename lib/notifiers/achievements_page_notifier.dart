// lib/notifiers/achievements_page_notifier.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/achievement.dart';
import 'package:mincloset/models/badge.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/repository_providers.dart';

class AchievementsPageState extends Equatable {
  final bool isLoading;
  final List<Badge> allBadges;
  final List<Achievement> allAchievements; // <<< THÊM DÒNG NÀY
  final Set<String> unlockedBadgeIds;
  final List<Quest> inProgressQuests;
  final Map<String, List<Quest>> completedQuestsByAchievement; // <<< THAY ĐỔI DÒNG NÀY

  const AchievementsPageState({
    this.isLoading = true,
    this.allBadges = const [],
    this.allAchievements = const [], // <<< THÊM DÒNG NÀY
    this.unlockedBadgeIds = const {},
    this.inProgressQuests = const [],
    this.completedQuestsByAchievement = const {}, // <<< THAY ĐỔI DÒNG NÀY
  });

  AchievementsPageState copyWith({
    bool? isLoading,
    List<Badge>? allBadges,
    List<Achievement>? allAchievements, // <<< THÊM DÒNG NÀY
    Set<String>? unlockedBadgeIds,
    List<Quest>? inProgressQuests,
    Map<String, List<Quest>>? completedQuestsByAchievement, // <<< THAY ĐỔI DÒNG NÀY
  }) {
    return AchievementsPageState(
      isLoading: isLoading ?? this.isLoading,
      allBadges: allBadges ?? this.allBadges,
      allAchievements: allAchievements ?? this.allAchievements, // <<< THÊM DÒNG NÀY
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      inProgressQuests: inProgressQuests ?? this.inProgressQuests,
      completedQuestsByAchievement: completedQuestsByAchievement ?? this.completedQuestsByAchievement, // <<< THAY ĐỔI DÒNG NÀY
    );
  }

  @override
  List<Object?> get props => [isLoading, allBadges, allAchievements, unlockedBadgeIds, inProgressQuests, completedQuestsByAchievement];
}

class AchievementsPageNotifier extends StateNotifier<AchievementsPageState> {
  final Ref _ref;

  AchievementsPageNotifier(this._ref) : super(const AchievementsPageState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    final achievementRepo = _ref.read(achievementRepositoryProvider);
    final questRepo = _ref.read(questRepositoryProvider);

    final allQuests = questRepo.getCurrentQuests();
    final allAchievements = achievementRepo.getAllAchievements();
    final allBadges = achievementRepo.getAllBadges();
    final unlockedAchievementIds = achievementRepo.getUnlockedAchievementIds();

    final unlockedBadgeIds = unlockedAchievementIds.map((achieveId) {
      return allAchievements.firstWhere((a) => a.id == achieveId).badgeId;
    }).toSet();
    
    // <<< LOGIC MỚI: NHÓM CÁC QUEST ĐÃ HOÀN THÀNH >>>
    final Map<String, List<Quest>> completedMap = {};
    final completedQuests = allQuests.where((q) => q.status == QuestStatus.completed).toList();
    for (final achievement in allAchievements) {
      completedMap[achievement.id] = completedQuests
          .where((quest) => achievement.requiredQuestIds.contains(quest.id))
          .toList();
    }

    state = state.copyWith(
      isLoading: false,
      allBadges: allBadges,
      allAchievements: allAchievements, // Cung cấp ds achievements cho UI
      unlockedBadgeIds: unlockedBadgeIds,
      inProgressQuests: allQuests.where((q) => q.status == QuestStatus.inProgress).toList(),
      completedQuestsByAchievement: completedMap, // Thay thế ds completed cũ
    );
  }
}

final achievementsPageProvider = StateNotifierProvider.autoDispose<AchievementsPageNotifier, AchievementsPageState>((ref) {
  return AchievementsPageNotifier(ref);
});