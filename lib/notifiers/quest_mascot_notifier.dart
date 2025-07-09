// lib/notifiers/quest_mascot_notifier.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/providers/service_providers.dart';

class QuestMascotState {
  final bool isVisible;
  final Offset? position;
  
  // THAY ĐỔI 1: Hợp nhất các trạng thái thông báo
  final bool showNotification;
  final String notificationText;
  Timer? _dismissTimer;

  QuestMascotState({
    this.isVisible = false,
    this.position,
    this.showNotification = false,
    this.notificationText = '',
  });

  QuestMascotState copyWith({
    bool? isVisible,
    Offset? position,
    bool? showNotification,
    String? notificationText,
  }) {
    return QuestMascotState(
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
      showNotification: showNotification ?? this.showNotification,
      notificationText: notificationText ?? this.notificationText,
    );
  }
}

final questMascotProvider = StateNotifierProvider.autoDispose<QuestMascotNotifier, QuestMascotState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return QuestMascotNotifier(prefs);
});

class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final SharedPreferences? _prefs;
  static const String _positionDxKey = 'quest_mascot_pos_dx';
  static const String _positionDyKey = 'quest_mascot_pos_dy';

  QuestMascotNotifier(this._prefs) : super(QuestMascotState()) {
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

  void dismiss() {
    state = state.copyWith(isVisible: false, showNotification: false);
    state._dismissTimer?.cancel();
  }

  void updatePosition(Offset newPosition) {
    _prefs?.setDouble(_positionDxKey, newPosition.dx);
    _prefs?.setDouble(_positionDyKey, newPosition.dy);
    state = state.copyWith(position: newPosition);
  }
  
  void hideNotification() {
    state._dismissTimer?.cancel();
    state = state.copyWith(showNotification: false);
  }

  // THAY ĐỔI 2: Tạo một hàm showNotification linh hoạt
  void showNotification(String text) {
    state._dismissTimer?.cancel();

    state = state.copyWith(
      isVisible: true,
      showNotification: true,
      notificationText: text,
    );
    
    // Tự động ẩn thông báo sau 5 giây
    state._dismissTimer = Timer(const Duration(seconds: 5), () {
      hideNotification();
    });
  }
}