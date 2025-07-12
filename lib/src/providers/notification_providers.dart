// lib/src/providers/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/src/data/repositories/notification_settings_repository_impl.dart';
import 'package:mincloset/src/domain/models/notification_settings.dart';
import 'package:mincloset/src/domain/repositories/notification_settings_repository.dart';
import 'package:mincloset/src/services/local_notification_service.dart';

// Provider cho Notification Service
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

// Provider cho Repository
final notificationSettingsRepositoryProvider = Provider<INotificationSettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception("SharedPreferences not initialized for NotificationSettingsRepository");
  }
  return NotificationSettingsRepositoryImpl(prefs);
});

// Provider để quản lý State và Logic của trang cài đặt
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref);
});

// Lớp Notifier để xử lý logic
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final Ref _ref;
  late final INotificationSettingsRepository _repository;
  late final LocalNotificationService _service;

  NotificationSettingsNotifier(this._ref) : super(const NotificationSettings()) {
    _repository = _ref.read(notificationSettingsRepositoryProvider);
    _service = _ref.read(localNotificationServiceProvider);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = await _repository.getSettings();
    _rescheduleNotifications();
  }

  Future<void> updateMaster(bool isEnabled) async {
    state = state.copyWith(isMasterEnabled: isEnabled);
    await _repository.saveSettings(state);
    _rescheduleNotifications();
  }

  Future<void> updateMorning(bool isEnabled) async {
    state = state.copyWith(isMorningReminderEnabled: isEnabled);
    await _repository.saveSettings(state);
    _rescheduleNotifications();
  }

  Future<void> updateEvening(bool isEnabled) async {
    state = state.copyWith(isEveningReminderEnabled: isEnabled);
    await _repository.saveSettings(state);
    _rescheduleNotifications();
  }

  void _rescheduleNotifications() {
    _service.cancelAllNotifications();

    if (state.isMasterEnabled) {
      if (state.isMorningReminderEnabled) {
        _service.scheduleMorningReminder();
      }
      if (state.isEveningReminderEnabled) {
        _service.scheduleEveningReminder();
      }
    }
  }
}