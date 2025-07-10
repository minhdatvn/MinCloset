// lib/notifiers/achievements_page_notifier.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/badge.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/repository_providers.dart';

// State chứa tất cả dữ liệu cần thiết cho UI
class AchievementsPageState extends Equatable {
  final bool isLoading;
  final List<Badge> allBadges;
  final Set<String> unlockedBadgeIds;
  final List<Quest> inProgressQuests;
  final List<Quest> completedQuests;

  const AchievementsPageState({
    this.isLoading = true,
    this.allBadges = const [],
    this.unlockedBadgeIds = const {},
    this.inProgressQuests = const [],
    this.completedQuests = const [],
  });

  AchievementsPageState copyWith({
    bool? isLoading,
    List<Badge>? allBadges,
    Set<String>? unlockedBadgeIds,
    List<Quest>? inProgressQuests,
    List<Quest>? completedQuests,
  }) {
    return AchievementsPageState(
      isLoading: isLoading ?? this.isLoading,
      allBadges: allBadges ?? this.allBadges,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      inProgressQuests: inProgressQuests ?? this.inProgressQuests,
      completedQuests: completedQuests ?? this.completedQuests,
    );
  }

  @override
  List<Object?> get props => [isLoading, allBadges, unlockedBadgeIds, inProgressQuests, completedQuests];
}

// Notifier quản lý việc tải dữ liệu
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

    // Lấy ra các ID của huy hiệu đã được mở khóa
    final unlockedBadgeIds = unlockedAchievementIds.map((achieveId) {
      return allAchievements.firstWhere((a) => a.id == achieveId).badgeId;
    }).toSet();

    state = state.copyWith(
      isLoading: false,
      allBadges: allBadges,
      unlockedBadgeIds: unlockedBadgeIds,
      inProgressQuests: allQuests.where((q) => q.status == QuestStatus.inProgress).toList(),
      completedQuests: allQuests.where((q) => q.status == QuestStatus.completed).toList(),
    );
  }
}

// Provider cho trang mới
final achievementsPageProvider = StateNotifierProvider.autoDispose<AchievementsPageNotifier, AchievementsPageState>((ref) {
  return AchievementsPageNotifier(ref);
});