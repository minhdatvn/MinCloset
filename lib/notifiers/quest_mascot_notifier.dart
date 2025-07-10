// lib/notifiers/quest_mascot_notifier.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/quest.dart'; // Thêm import này
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MascotNotificationType {
  none,
  newQuestAvailable,
  questCompleted,
}

class QuestMascotState {
  final bool isVisible;
  final Offset? position;
  final Offset? originalPositionBeforeNotification;
  final MascotNotificationType notificationType;
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

final questMascotProvider = StateNotifierProvider.autoDispose<QuestMascotNotifier, QuestMascotState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return QuestMascotNotifier(prefs, ref);
});

class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final SharedPreferences? _prefs;
  final Ref _ref;
  // THAY ĐỔI 1: Key mới để lưu danh sách các ID đã xem
  static const String _seenQuestIdsKey = 'seen_quest_ids';
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

  // THAY ĐỔI 2: Hàm helper để lấy các quest chưa xem
  List<Quest> _getUnseenActiveQuests() {
    final allActiveQuests = _ref.read(questRepositoryProvider).getCurrentQuests().where((q) => q.status == QuestStatus.inProgress).toList();
    final seenIds = _prefs?.getStringList(_seenQuestIdsKey)?.toSet() ?? {};
    return allActiveQuests.where((quest) => !seenIds.contains(quest.id)).toList();
  }

  // THAY ĐỔI 3: Hàm này sẽ đánh dấu tất cả các quest đang active là đã xem
  void markCurrentQuestsAsSeen() {
    final allActiveQuests = _ref.read(questRepositoryProvider).getCurrentQuests().where((q) => q.status == QuestStatus.inProgress).toList();
    final seenIds = _prefs?.getStringList(_seenQuestIdsKey)?.toSet() ?? {};
    
    for (var quest in allActiveQuests) {
      seenIds.add(quest.id);
    }
    
    _prefs?.setStringList(_seenQuestIdsKey, seenIds.toList());
    // Sau khi đánh dấu là đã xem, ẩn thông báo "New Quest!"
    if (state.notificationType == MascotNotificationType.newQuestAvailable) {
        state = state.copyWith(notificationType: MascotNotificationType.none);
    }
  }
  
  // THAY ĐỔI 4: Logic hiển thị "New Quest!" được nâng cấp
  void checkForNewQuests() {
    state._dismissTimer?.cancel();
    final unseenQuests = _getUnseenActiveQuests();

    if (unseenQuests.isNotEmpty) {
      state = state.copyWith(
        isVisible: true,
        notificationType: MascotNotificationType.newQuestAvailable,
        notificationMessage: 'New Quest!',
      );
    } else {
      state = state.copyWith(notificationType: MascotNotificationType.none);
    }
  }

  void showQuestCompletedNotification(String questTitle, double screenWidth) {
    state._dismissTimer?.cancel();
    _moveMascotForNotification(screenWidth);

    state = state.copyWith(
      isVisible: true,
      notificationType: MascotNotificationType.questCompleted,
      notificationMessage: 'Quest Completed!',
    );

    state._dismissTimer = Timer(const Duration(seconds: 5), () {
      hideCurrentNotificationAndCheckForNew();
    });
  }
  
  // THAY ĐỔI 5: Hàm này giờ sẽ ẩn thông báo hiện tại và gọi hàm kiểm tra quest mới
  void hideCurrentNotificationAndCheckForNew() {
    state._dismissTimer?.cancel();
    _restoreMascotPosition();
    state = state.copyWith(notificationType: MascotNotificationType.none);
    
    // Sau khi ẩn, gọi hàm kiểm tra lại
    checkForNewQuests();
  }
}