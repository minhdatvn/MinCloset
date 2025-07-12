// lib/notifiers/quest_mascot_notifier.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/service_providers.dart';
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
    _loadState();
  }

  void _loadState() {
    if (_prefs == null) return;
    final dx = _prefs!.getDouble(_positionDxKey);
    final dy = _prefs!.getDouble(_positionDyKey);
    if (dx != null && dy != null) {
      // Cập nhật state với vị trí đã lưu
      if (mounted) {
        state = state.copyWith(position: Offset(dx, dy));
      }
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

  void showNewQuestNotification(double screenWidth) {
    _notificationTimer?.cancel();
    if (mounted) {
      state = state.copyWith(
        isVisible: true,
        notificationType: MascotNotificationType.newQuest,
        notificationMessage: 'New Quest!',
      );
    }
    _notificationTimer = Timer(const Duration(seconds: 4), () {
      hideCurrentNotification();
      // Sau khi ẩn thông báo, gọi hàm bám biên
      _snapToEdge(screenWidth);
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
      if (mounted && state.originalPosition != null) {
        // Cập nhật lại vị trí gốc trước
        state = state.copyWith(
          position: state.originalPosition,
          clearOriginalPosition: true,
        );
        // Sau đó ngay lập tức gọi hàm bám biên
        _snapToEdge(screenWidth);
      }
      hideCurrentNotification();
    });
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

  void dismiss() {
    _notificationTimer?.cancel();
    if (mounted) {
      state = state.copyWith(isVisible: false);
    }
  }
}

// THAY ĐỔI 2: Sửa lại cách khởi tạo provider
final questMascotProvider =
    StateNotifierProvider<QuestMascotNotifier, QuestMascotState>(
  (ref) {
    // Provider giờ chỉ cần truyền ref vào, không cần watch SharedPreferences ở đây nữa
    return QuestMascotNotifier(ref);
  },
);