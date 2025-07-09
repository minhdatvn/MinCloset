// lib/repositories/quest_repository.dart

import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/services/quest_service.dart';

// Repository đóng vai trò là cầu nối, giúp các Notifier/UseCase không cần biết về QuestService
class QuestRepository {
  final QuestService _questService;

  QuestRepository(this._questService);

  List<Quest> getCurrentQuests() {
    return _questService.getCurrentQuests();
  }

  Future<void> updateQuestProgress(ClothingItem newItem) {
    return _questService.updateQuestProgress(newItem);
  }

  Quest? getFirstActiveQuest() {
    return _questService.getFirstActiveQuest();
  }
}