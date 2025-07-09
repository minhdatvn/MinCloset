// lib/notifiers/quests_page_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/quest_repository.dart';

// Provider này chỉ lấy ra nhiệm vụ đang hoạt động đầu tiên.
// Dùng cho nút FAB. '.autoDispose' để nó tự làm mới khi cần.
final activeQuestProvider = Provider.autoDispose<Quest?>((ref) {
  final questRepo = ref.watch(questRepositoryProvider);
  // Theo dõi sự thay đổi của item để provider này tự cập nhật
  ref.watch(itemChangedTriggerProvider); 
  return questRepo.getFirstActiveQuest();
});

// Provider này quản lý state của toàn bộ trang nhiệm vụ.
final questsPageProvider = StateNotifierProvider.autoDispose<QuestsPageNotifier, List<Quest>>((ref) {
  final questRepo = ref.watch(questRepositoryProvider);
  return QuestsPageNotifier(questRepo, ref);
});


class QuestsPageNotifier extends StateNotifier<List<Quest>> {
  final QuestRepository _questRepo;
  final Ref _ref;

  QuestsPageNotifier(this._questRepo, this._ref) : super([]) {
    loadQuests();

    // Lắng nghe sự kiện item thay đổi để tự động tải lại danh sách nhiệm vụ
    _ref.listen(itemChangedTriggerProvider, (previous, next) {
      if (previous != next) {
        loadQuests();
      }
    });
  }

  void loadQuests() {
    state = _questRepo.getCurrentQuests();
  }
}