// lib/notifiers/quest_fab_notifier.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/providers/service_providers.dart';

// Đổi tên State để rõ ràng hơn
class QuestMascotState {
  final bool isVisible;
  final Offset position;

  const QuestMascotState({this.isVisible = true, this.position = const Offset(280, 550)}); // Vị trí mặc định mới

  QuestMascotState copyWith({bool? isVisible, Offset? position}) {
    return QuestMascotState(
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
    );
  }
}

final questMascotProvider = StateNotifierProvider.autoDispose<QuestMascotNotifier, QuestMascotState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return QuestMascotNotifier(prefs);
});

class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final SharedPreferences? _prefs;
  // Các key để lưu vào bộ nhớ
  static const String _dismissedKey = 'quest_mascot_dismissed';
  static const String _positionDxKey = 'quest_mascot_pos_dx';
  static const String _positionDyKey = 'quest_mascot_pos_dy';

  QuestMascotNotifier(this._prefs) : super(const QuestMascotState()) {
    _loadState();
  }

  // Tải trạng thái (ẩn/hiện và vị trí) từ SharedPreferences
  void _loadState() {
    if (_prefs == null) return;

    final isDismissed = _prefs!.getBool(_dismissedKey) ?? false;
    final dx = _prefs!.getDouble(_positionDxKey);
    final dy = _prefs!.getDouble(_positionDyKey);

    // Nếu có vị trí đã lưu, sử dụng nó
    if (dx != null && dy != null) {
      state = QuestMascotState(isVisible: !isDismissed, position: Offset(dx, dy));
    } else {
      // Nếu không, chỉ cập nhật trạng thái ẩn/hiện
      state = state.copyWith(isVisible: !isDismissed);
    }
  }

  // Hàm để ẩn mascot
  void dismiss() {
    _prefs?.setBool(_dismissedKey, true);
    state = state.copyWith(isVisible: false);
  }

  // Hàm để cập nhật vị trí mới và lưu lại
  void updatePosition(Offset newPosition) {
    _prefs?.setDouble(_positionDxKey, newPosition.dx);
    _prefs?.setDouble(_positionDyKey, newPosition.dy);
    state = state.copyWith(position: newPosition);
  }
}