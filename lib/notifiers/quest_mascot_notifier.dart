// lib/notifiers/quest_mascot_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MascotNotificationType { none, newQuest, questCompleted }

@immutable
class QuestMascotState {
  final Offset? position;
  final bool isVisible;
  final MascotNotificationType notificationType;
  final String notificationMessage;
  final Offset? originalPosition;

  const QuestMascotState({
    this.position,
    this.isVisible = false,
    this.notificationType = MascotNotificationType.none,
    this.notificationMessage = '',
    this.originalPosition,
  });

  QuestMascotState copyWith({
    Offset? position,
    bool? isVisible,
    MascotNotificationType? notificationType,
    String? notificationMessage,
    Offset? originalPosition,
    bool clearOriginalPosition = false,
  }) {
    return QuestMascotState(
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
      notificationType: notificationType ?? this.notificationType,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      originalPosition:
          clearOriginalPosition ? null : originalPosition ?? this.originalPosition,
    );
  }
}

// THAY ĐỔI 1: Sửa lại Notifier để nó tự khởi tạo bất đồng bộ
class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final Ref _ref;
  SharedPreferences? _prefs;
  Timer? _notificationTimer;

  static const _positionDxKey = 'mascot_position_dx';
  static const _positionDyKey = 'mascot_position_dy';

  QuestMascotNotifier(this._ref) : super(const QuestMascotState()) {
    // Gọi hàm khởi tạo bất đồng bộ
    _init();
  }

  // Hàm này sẽ chạy ngầm để lấy SharedPreferences
  Future<void> _init() async {
    // Chờ cho đến khi SharedPreferences sẵn sàng
    _prefs = await _ref.read(sharedPreferencesProvider.future);
    // Khi đã có, tiến hành load state
    loadState();
  // Lắng nghe sự thay đổi của cài đặt từ ProfileProvider
    _ref.listen<bool>(profileProvider.select((s) => s.showMascot), (previous, next) {
      final hasCompletedTutorial = _prefs?.getBool('has_completed_tutorial') ?? false;
      if (mounted && hasCompletedTutorial) {
        state = state.copyWith(isVisible: next);
      }
    });
  }

  void loadState() {
    if (_prefs == null) return;
    final dx = _prefs!.getDouble(_positionDxKey);
    final dy = _prefs!.getDouble(_positionDyKey);

    // Kiểm tra xem người dùng đã hoàn thành hướng dẫn chưa
    final bool hasCompletedTutorial = _prefs!.getBool('has_completed_tutorial') ?? false;
    final bool showMascotSetting = _prefs!.getBool(SettingsRepository.showMascotKey) ?? true;

    if (mounted) {
      state = state.copyWith(
        // Cập nhật vị trí đã lưu như cũ
        position: (dx != null && dy != null) ? Offset(dx, dy) : null,
        // ĐẶT TRẠNG THÁI HIỂN THỊ DỰA VÀO CỜ ĐÃ LƯU
        isVisible: hasCompletedTutorial && showMascotSetting,
      );
    }
  }

  Future<void> updatePosition(Offset newPosition) async {
    // Chờ _prefs sẵn sàng nếu cần
    if (_prefs == null) await _init();
    if (mounted) {
      state = state.copyWith(position: newPosition);
    }
    await _prefs?.setDouble(_positionDxKey, newPosition.dx);
    await _prefs?.setDouble(_positionDyKey, newPosition.dy);
  }

  // <<< HÀM ĐỂ MASCOT BÁM VÀO BIÊN >>>
  void _snapToEdge(double screenWidth) {
    if (state.position == null) return;
    
    const double mascotWidth = 80.0;
    const double padding = 16.0;
    double newDx;

    // Kiểm tra xem mascot đang ở nửa bên nào của màn hình
    if ((state.position!.dx + mascotWidth / 2) < screenWidth / 2) {
      newDx = padding; // Bám vào cạnh trái
    } else {
      newDx = screenWidth - mascotWidth - padding; // Bám vào cạnh phải
    }

    // Cập nhật vị trí mới
    final newPosition = Offset(newDx, state.position!.dy);
    updatePosition(newPosition);
  }

  void showNewQuestNotification(String questId) {
    _notificationTimer?.cancel();
    if (mounted) {
      state = state.copyWith(
        isVisible: true,
        notificationType: MascotNotificationType.newQuest,
        notificationMessage: 'New Quest!',
      );
    }

    // Logic lưu lại quest đã xem (giữ nguyên)
    final seenIds = _prefs?.getStringList('seen_new_quest_ids')?.toList() ?? [];
    if (!seenIds.contains(questId)) {
      seenIds.add(questId);
      _prefs?.setStringList('seen_new_quest_ids', seenIds);
    }

    _notificationTimer = Timer(const Duration(seconds: 4), () {
      hideCurrentNotification();
    });
  }

  void showQuestCompletedNotification(String title, double screenWidth) {
    _notificationTimer?.cancel();
    final currentPosition = state.position;
    if (currentPosition == null) return;

    final newPos = Offset(screenWidth / 2 - 40, currentPosition.dy);

    if (mounted) {
      state = state.copyWith(
        isVisible: true,
        position: newPos,
        originalPosition: currentPosition,
        notificationType: MascotNotificationType.questCompleted,
        notificationMessage: 'Quest Completed!',
      );
    }

    _notificationTimer = Timer(const Duration(seconds: 3), () {
      // Ẩn thông báo "Quest Completed" đi
      hideCurrentNotification();

      // Di chuyển mascot về vị trí cũ (không đổi)
      if (mounted && state.originalPosition != null) {
        state = state.copyWith(
          position: state.originalPosition,
          clearOriginalPosition: true,
        );
        _snapToEdge(screenWidth);
      }
      
      // Bắt đầu thay đổi: Gọi hàm có sẵn của bạn tại đây
      checkForNewQuests(); 
      // Kết thúc thay đổi
    });
  }

  void checkForNewQuests() {
    if (state.notificationType != MascotNotificationType.none || !state.isVisible) {
      return;
    }

    final questRepo = _ref.read(questRepositoryProvider);
    final allQuests = questRepo.getCurrentQuests();
    final seenQuestIds = _prefs?.getStringList('seen_new_quest_ids')?.toSet() ?? {};
    
    Quest? newQuestToShow; // Khai báo biến có thể null

    try {
      // Dùng try-catch để bắt lỗi khi không tìm thấy
      newQuestToShow = allQuests.firstWhere(
        (quest) => !seenQuestIds.contains(quest.id) && quest.status == QuestStatus.inProgress,
      );
    } catch (e) {
      // Bắt lỗi StateError khi firstWhere không tìm thấy phần tử nào
      // Gán newQuestToShow = null để xử lý ở bước tiếp theo
      newQuestToShow = null;
    }
    
    // Bây giờ, điều kiện kiểm tra null là cần thiết và chính xác
    if (newQuestToShow != null) {
      // Truyền questId (String) vào hàm đã được sửa
      showNewQuestNotification(newQuestToShow.id);
    }
  }

  void hideCurrentNotification() {
    _notificationTimer?.cancel();
    if (mounted) {
      state = state.copyWith(
        notificationType: MascotNotificationType.none,
        notificationMessage: '',
      );
    }
  }

  Future<void> finishTutorialAndShowMascot() async {
    // Đảm bảo SharedPreferences đã được khởi tạo
    if (_prefs == null) await _init();
    
    // 1. Lưu lại trạng thái đã hoàn thành hướng dẫn
    await _prefs?.setBool('has_completed_tutorial', true);

    // 2. Cập nhật state để làm cho mascot hiển thị ngay lập tức
    if (mounted) {
      state = state.copyWith(isVisible: true);
    }

    // 3. Đợi một chút để mascot kịp xuất hiện trên màn hình
    await Future.delayed(const Duration(milliseconds: 500));

    // 4. Gọi hàm kiểm tra quest mới. Vì isVisible bây giờ đã là true,
    // điều kiện bên trong checkForNewQuests() sẽ thỏa mãn.
    if (mounted) {
      checkForNewQuests();
    }
  }

  void dismiss() {
    _notificationTimer?.cancel();
    _ref.read(profileProvider.notifier).updateShowMascot(false);
  }
}

final questMascotProvider =
    StateNotifierProvider<QuestMascotNotifier, QuestMascotState>(
  (ref) {
    // Provider giờ chỉ cần truyền ref vào, không cần watch SharedPreferences ở đây nữa
    return QuestMascotNotifier(ref);
  },
);