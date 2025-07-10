// lib/notifiers/quest_mascot_notifier.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// THAY ĐỔI 1: Tạo enum để quản lý các loại thông báo một cách rõ ràng
enum MascotNotificationType {
  none,
  newQuestAvailable,
  questCompleted,
}

class QuestMascotState {
  final bool isVisible;
  final Offset? position;
  final Offset? originalPositionBeforeNotification;

  // THAY ĐỔI 2: Dùng enum để quản lý trạng thái thông báo
  final MascotNotificationType notificationType;
  // Dùng để chứa nội dung thông báo (ví dụ: tên quest đã hoàn thành)
  final String notificationMessage;
  Timer? _dismissTimer;

  QuestMascotState({
    this.isVisible = false,
    this.position,
    this.originalPositionBeforeNotification,
    this.notificationType = MascotNotificationType.none,
    this.notificationMessage = '',
  });

  QuestMascotState copyWith({
    bool? isVisible,
    Offset? position,
    Offset? originalPositionBeforeNotification,
    bool clearOriginalPosition = false,
    MascotNotificationType? notificationType,
    String? notificationMessage,
  }) {
    return QuestMascotState(
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
      originalPositionBeforeNotification: clearOriginalPosition ? null : originalPositionBeforeNotification ?? this.originalPositionBeforeNotification,
      notificationType: notificationType ?? this.notificationType,
      notificationMessage: notificationMessage ?? this.notificationMessage,
    );
  }
}

// Provider không đổi
final questMascotProvider = StateNotifierProvider.autoDispose<QuestMascotNotifier, QuestMascotState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  // THAY ĐỔI 3: Cung cấp `ref` cho Notifier để nó có thể đọc các provider khác
  return QuestMascotNotifier(prefs, ref);
});

class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final SharedPreferences? _prefs;
  // THAY ĐỔI 4: Lưu lại `ref` để sử dụng
  final Ref _ref;
  static const String _positionDxKey = 'quest_mascot_pos_dx';
  static const String _positionDyKey = 'quest_mascot_pos_dy';
  final double mascotWidth = 80.0;

  QuestMascotNotifier(this._prefs, this._ref) : super(QuestMascotState()) {
    _loadState();
  }

  void _loadState() {
    if (_prefs == null) return;
    final dx = _prefs!.getDouble(_positionDxKey);
    final dy = _prefs!.getDouble(_positionDyKey);
    if (dx != null && dy != null) {
      state = state.copyWith(position: Offset(dx, dy));
    }
  }
  
  void updatePosition(Offset newPosition) {
    _prefs?.setDouble(_positionDxKey, newPosition.dx);
    _prefs?.setDouble(_positionDyKey, newPosition.dy);
    state = state.copyWith(position: newPosition);
  }

  void dismiss() {
    state._dismissTimer?.cancel();
    state = state.copyWith(isVisible: false, notificationType: MascotNotificationType.none);
  }

  // THAY ĐỔI 5: Nâng cấp toàn bộ logic xử lý thông báo
  void _moveMascotForNotification(double screenWidth) {
    Offset? newPosition;
    Offset? originalPosition;
    final currentDx = state.position?.dx ?? screenWidth - mascotWidth - 16.0;

    if (currentDx < 1.0 || currentDx > screenWidth - mascotWidth - 1.0) {
      originalPosition = state.position;
      newPosition = Offset((screenWidth - mascotWidth) / 2, state.position?.dy ?? 450.0);
      
      state = state.copyWith(
        position: newPosition,
        originalPositionBeforeNotification: originalPosition,
      );
    }
  }

  void _restoreMascotPosition() {
    final positionToRestore = state.originalPositionBeforeNotification;
    if (positionToRestore != null) {
      state = state.copyWith(
        position: positionToRestore,
        clearOriginalPosition: true,
      );
    }
  }

  // Hiển thị thông báo có nhiệm vụ mới
  void showNewQuestNotification() {
    state._dismissTimer?.cancel();
    state = state.copyWith(
      isVisible: true,
      notificationType: MascotNotificationType.newQuestAvailable,
      notificationMessage: 'New Quest!',
    );
  }

  // Hiển thị thông báo hoàn thành nhiệm vụ
  void showQuestCompletedNotification(String questTitle, double screenWidth) {
    state._dismissTimer?.cancel();
    _moveMascotForNotification(screenWidth);

    state = state.copyWith(
      isVisible: true,
      notificationType: MascotNotificationType.questCompleted,
      notificationMessage: 'Quest Completed!',
    );

    // Tự động chuyển trạng thái sau 5 giây
    state._dismissTimer = Timer(const Duration(seconds: 5), () {
      hideCurrentNotification();
    });
  }

  // Ẩn thông báo hiện tại và kiểm tra xem có cần hiện "New Quest!" không
  void hideCurrentNotification() {
    state._dismissTimer?.cancel();
    _restoreMascotPosition();
    state = state.copyWith(notificationType: MascotNotificationType.none);

    // KIỂM TRA ĐIỀU KIỆN KẾ TIẾP: Sau khi ẩn, kiểm tra xem có quest nào đang hoạt động không
    final activeQuest = _ref.read(questRepositoryProvider).getFirstActiveQuest();
    if (activeQuest != null) {
      showNewQuestNotification();
    }
  }
}