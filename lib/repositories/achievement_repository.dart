// lib/repositories/achievement_repository.dart
import 'package:mincloset/models/achievement.dart';
import 'package:mincloset/models/badge.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/services/achievement_service.dart';

class AchievementRepository {
  final AchievementService _service;

  AchievementRepository(this._service);

  List<Badge> getAllBadges() => _service.getAllBadges();
  
  List<Achievement> getAllAchievements() => _service.getAllAchievements();

  Set<String> getUnlockedAchievementIds() => _service.getUnlockedAchievementIds();

  Future<Achievement?> checkAndUnlockAchievements(List<Quest> allQuests) =>
      _service.checkAndUnlockAchievements(allQuests);
}