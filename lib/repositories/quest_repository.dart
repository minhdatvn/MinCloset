// lib/repositories/quest_repository.dart
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/services/quest_service.dart';

class QuestRepository {
  final QuestService _questService;
  QuestRepository(this._questService);

  List<Quest> getCurrentQuests() => _questService.getCurrentQuests();
  Future<List<Quest>> updateQuestProgress(QuestEvent event) => _questService.updateQuestProgress(event);
  Quest? getFirstActiveQuest() => _questService.getFirstActiveQuest();
}