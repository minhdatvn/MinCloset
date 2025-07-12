// lib/providers/ui_providers.dart

import 'package:flutter/material.dart'; // <<< THÊM IMPORT NÀY
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/notifiers/tutorial_notifier.dart';
import 'package:mincloset/routing/app_routes.dart';
import 'package:mincloset/states/tutorial_state.dart';

/// Provider này sẽ lưu trạng thái của tab đang được chọn trên MainScreen.
/// 0: Trang chủ, 1: Tủ đồ, 2: Trang phục, 3: Cá nhân
final mainScreenIndexProvider = StateProvider<int>((ref) => 0);
/// Provider để điều khiển sub-tab của trang Closets. 0: All Items, 1: By Closet.
final closetsSubTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider quản lý trạng thái và logic của luồng hướng dẫn cho người mới.
final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  return TutorialNotifier();
});

/// Provider để theo dõi xem trang Quests có đang được hiển thị hay không.
final isQuestsPageActiveProvider = StateProvider<bool>((ref) => false);


// ===================================================================
// <<< BẮT ĐẦU THÊM MÃ MỚI TỪ ĐÂY >>>

/// Lớp này chứa tất cả các GlobalKey được sử dụng cho tính năng gợi ý nhiệm vụ.
/// Việc tập trung các key vào một nơi giúp quản lý dễ dàng hơn.
class QuestHintKeys {
  static final addItemHintKey = GlobalKey();
  static final getSuggestionHintKey = GlobalKey();
  static final createOutfitHintKey = GlobalKey();
  static final createClosetHintKey = GlobalKey();
  static final logWearHintKey = GlobalKey();
}

/// Lớp trạng thái cho gợi ý, chứa thông tin cần thiết để điều hướng và hiển thị.
@immutable
class QuestHintState {
  final GlobalKey? hintKey;
  final int? targetPageIndex;
  final int? targetSubTabIndex; // Dùng cho các trang có tab lồng nhau (vd: ClosetsPage)
  final String? routeName; // Dùng cho các trang không nằm trên thanh điều hướng chính
  
  // Dùng một ID duy nhất để đảm bảo provider luôn cập nhật, ngay cả khi hintKey giống nhau
  final int triggerId; 

  const QuestHintState({
    this.hintKey,
    this.targetPageIndex,
    this.targetSubTabIndex,
    this.routeName,
    required this.triggerId,
  });
}

/// Notifier này đóng vai trò là bộ não trung tâm, điều phối việc hiển thị gợi ý.
class QuestHintNotifier extends StateNotifier<QuestHintState?> {
  final Ref _ref;

  QuestHintNotifier(this._ref) : super(null);

  void triggerHint(String hintKey) {
    int newTriggerId = (state?.triggerId ?? 0) + 1;

    switch (hintKey) {
      case 'add_item_hint':
        state = QuestHintState(
          hintKey: QuestHintKeys.addItemHintKey,
          targetPageIndex: 0, // Kích hoạt ở tab Home để thấy Action Card
          triggerId: newTriggerId,
        );
        break;
      case 'get_suggestion_hint':
        state = QuestHintState(
          hintKey: QuestHintKeys.getSuggestionHintKey,
          targetPageIndex: 0, // Tab Home
          triggerId: newTriggerId,
        );
        break;
      case 'create_outfit_hint':
        state = QuestHintState(
          hintKey: QuestHintKeys.createOutfitHintKey,
          targetPageIndex: 0, // Tab Home
          triggerId: newTriggerId,
        );
        break;
      case 'create_closet_hint':
        // Giờ chúng ta sẽ cập nhật provider của sub-tab
        _ref.read(closetsSubTabIndexProvider.notifier).state = 1;
        state = QuestHintState(
          hintKey: QuestHintKeys.createClosetHintKey,
          targetPageIndex: 1, // Vẫn điều hướng đến tab Closets chính
          triggerId: newTriggerId,
        );
        break;
      case 'log_wear_hint':
        state = QuestHintState(
          hintKey: QuestHintKeys.logWearHintKey,
          routeName: AppRoutes.calendar, // Điều hướng đến trang riêng
          triggerId: newTriggerId,
        );
        break;
    }
    // Sau khi kích hoạt, chuyển tab chính ngay lập tức
    if (state?.targetPageIndex != null) {
      _ref.read(mainScreenIndexProvider.notifier).state = state!.targetPageIndex!;
    }
  }

  /// Reset lại state sau khi gợi ý đã được hiển thị.
  void clearHint() {
    state = null;
  }
}

/// Provider cho bộ điều khiển gợi ý.
final questHintProvider = StateNotifierProvider<QuestHintNotifier, QuestHintState?>((ref) {
  return QuestHintNotifier(ref);
});

// <<< KẾT THÚC PHẦN MÃ MỚI >>>