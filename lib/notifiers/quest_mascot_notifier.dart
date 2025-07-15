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

// --- PHẦN ENUM VÀ STATE CLASS KHÔNG THAY ĐỔI ---
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

// --- PHẦN NOTIFIER ĐÃ ĐƯỢC DỌN DẸP ---
class QuestMascotNotifier extends StateNotifier<QuestMascotState> {
  final Ref _ref;
  final SharedPreferences _prefs; // Biến thành viên, không đổi
  Timer? _notificationTimer;

  static const _positionDxKey = 'mascot_position_dx';
  static const _positionDyKey = 'mascot_position_dy';

  QuestMascotNotifier(this._ref, this._prefs) : super(const QuestMascotState()) {
    // Gọi trực tiếp hàm loadState, không cần qua _init() nữa
    loadState();
    // Lắng nghe sự thay đổi của cài đặt từ ProfileProvider
    _ref.listen<bool>(profileProvider.select((s) => s.showMascot), (previous, next) {
      final hasCompletedTutorial = _prefs.getBool('has_completed_tutorial') ?? false;
      if (mounted && hasCompletedTutorial) {
        state = state.copyWith(isVisible: next);
      }
    });
  }

  void loadState() {
    final dx = _prefs.getDouble(_positionDxKey);
    final dy = _prefs.getDouble(_positionDyKey);

    final bool hasCompletedTutorial = _prefs.getBool('has_completed_tutorial') ?? false;
    final bool showMascotSetting = _prefs.getBool(SettingsRepository.showMascotKey) ?? true;

    if (mounted) {
      state = state.copyWith(
        position: (dx != null && dy != null) ? Offset(dx, dy) : null,
        isVisible: hasCompletedTutorial && showMascotSetting,
      );
    }
  }

  Future<void> updatePosition(Offset newPosition) async {
    if (mounted) {
      state = state.copyWith(position: newPosition);
    }
    await _prefs.setDouble(_positionDxKey, newPosition.dx);
    await _prefs.setDouble(_positionDyKey, newPosition.dy);
  }

  void _snapToEdge(double screenWidth) {
    if (state.position == null) return;
    
    const double mascotWidth = 80.0;
    const double padding = 16.0;
    double newDx;

    if ((state.position!.dx + mascotWidth / 2) < screenWidth / 2) {
      newDx = padding;
    } else {
      newDx = screenWidth - mascotWidth - padding;
    }

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

    final seenIds = _prefs.getStringList('seen_new_quest_ids')?.toList() ?? [];
    if (!seenIds.contains(questId)) {
      seenIds.add(questId);
      _prefs.setStringList('seen_new_quest_ids', seenIds);
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
      hideCurrentNotification();
      if (mounted && state.originalPosition != null) {
        state = state.copyWith(
          position: state.originalPosition,
          clearOriginalPosition: true,
        );
        _snapToEdge(screenWidth);
      }
      checkForNewQuests();
    });
  }

  void checkForNewQuests() {
    if (state.notificationType != MascotNotificationType.none || !state.isVisible) {
      return;
    }

    final questRepo = _ref.read(questRepositoryProvider);
    final allQuests = questRepo.getCurrentQuests();
    final seenQuestIds = _prefs.getStringList('seen_new_quest_ids')?.toSet() ?? {};
    
    Quest? newQuestToShow;

    try {
      newQuestToShow = allQuests.firstWhere(
        (quest) => !seenQuestIds.contains(quest.id) && quest.status == QuestStatus.inProgress,
      );
    } catch (e) {
      newQuestToShow = null;
    }
    
    if (newQuestToShow != null) {
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
    await _prefs.setBool('has_completed_tutorial', true);
    if (mounted) {
      state = state.copyWith(isVisible: true);
    }
    await Future.delayed(const Duration(milliseconds: 500));
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
    final prefs = ref.watch(sharedPreferencesProvider);
    return QuestMascotNotifier(ref, prefs);
  },
);