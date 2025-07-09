// lib/notifiers/quest_mascot_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/providers/service_providers.dart';

class QuestMascotState {
  final bool isVisible;
  final Offset? position;
  final bool showQuestNotification;

  const QuestMascotState({
    this.isVisible = false,
    this.position,
    this.showQuestNotification = false,
  });

  QuestMascotState copyWith({
    bool? isVisible,
    Offset? position,
    bool? showQuestNotification,
  }) {
    return QuestMascotState(
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
      showQuestNotification: showQuestNotification ?? this.showQuestNotification,
    );
  }
}

final questMascotProvider = StateNotifierProvider.autoDispose<QuestMascotNotifier, QuestMascotState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return QuestMascotNotifier(prefs);
});

class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final SharedPreferences? _prefs;
  static const String _dismissedKey = 'quest_mascot_dismissed';
  static const String _positionDxKey = 'quest_mascot_pos_dx';
  static const String _positionDyKey = 'quest_mascot_pos_dy';

  QuestMascotNotifier(this._prefs) : super(const QuestMascotState()) {
    _loadState();
  }

  void _loadState() {
    if (_prefs == null) return;
    
    // --- VÔ HIỆU HÓA VIỆC KIỂM TRA TRẠNG THÁI ĐÃ ẨN ---
    // final bool isDismissed = _prefs!.getBool(_dismissedKey) ?? false;
    // if (isDismissed) {
    //   state = state.copyWith(isVisible: false);
    //   return;
    // }

    final dx = _prefs!.getDouble(_positionDxKey);
    final dy = _prefs!.getDouble(_positionDyKey);

    if (dx != null && dy != null) {
      state = state.copyWith(position: Offset(dx, dy));
    }
  }

  void dismiss() {
    // --- VÔ HIỆU HÓA VIỆC LƯU TRẠNG THÁI ĐÃ ẨN ---
    // _prefs?.setBool(_dismissedKey, true);
    state = state.copyWith(isVisible: false);
  }

  void updatePosition(Offset newPosition) {
    _prefs?.setDouble(_positionDxKey, newPosition.dx);
    _prefs?.setDouble(_positionDyKey, newPosition.dy);
    state = state.copyWith(position: newPosition);
  }

  void showMascotWithQuestNotification() {
    // --- VÔ HIỆU HÓA VIỆC KIỂM TRA TRẠNG THÁI ĐÃ ẨN ---
    // final bool isDismissed = _prefs?.getBool(_dismissedKey) ?? false;
    // if (!isDismissed) {
      state = state.copyWith(isVisible: true, showQuestNotification: true);
    // }
  }

  void hideQuestNotification() {
    state = state.copyWith(showQuestNotification: false);
  }
}