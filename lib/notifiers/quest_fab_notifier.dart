// lib/notifiers/quest_fab_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mincloset/providers/service_providers.dart';

// THAY ĐỔI 1: Vị trí (position) giờ đây có thể là null ban đầu
class QuestMascotState {
  final bool isVisible;
  final Offset? position; // <-- Sửa thành Offset? (nullable)

  const QuestMascotState({this.isVisible = true, this.position});

  QuestMascotState copyWith({bool? isVisible, Offset? position}) {
    return QuestMascotState(
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
    );
  }
}

// provider không đổi
final questMascotProvider = StateNotifierProvider.autoDispose<QuestMascotNotifier, QuestMascotState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return QuestMascotNotifier(prefs);
});

class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final SharedPreferences? _prefs;
  static const String _dismissedKey = 'quest_mascot_dismissed';
  static const String _positionDxKey = 'quest_mascot_pos_dx';
  static const String _positionDyKey = 'quest_mascot_pos_dy';

  // THAY ĐỔI 2: Xóa vị trí mặc định trong constructor
  QuestMascotNotifier(this._prefs) : super(const QuestMascotState()) {
    _loadState();
  }

  void _loadState() {
    if (_prefs == null) return;
    final isDismissed = _prefs!.getBool(_dismissedKey) ?? false;
    final dx = _prefs!.getDouble(_positionDxKey);
    final dy = _prefs!.getDouble(_positionDyKey);

    // Chỉ tải lại vị trí nếu nó thực sự tồn tại
    if (dx != null && dy != null) {
      state = QuestMascotState(isVisible: !isDismissed, position: Offset(dx, dy));
    } else {
      state = state.copyWith(isVisible: !isDismissed);
    }
  }

  // Hàm dismiss không đổi
  void dismiss() {
    _prefs?.setBool(_dismissedKey, true);
    state = state.copyWith(isVisible: false);
  }

  // Hàm updatePosition không đổi
  void updatePosition(Offset newPosition) {
    _prefs?.setDouble(_positionDxKey, newPosition.dx);
    _prefs?.setDouble(_positionDyKey, newPosition.dy);
    state = state.copyWith(position: newPosition);
  }
}