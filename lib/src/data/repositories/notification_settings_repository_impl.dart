// lib/src/data/repositories/notification_settings_repository_impl.dart

import 'package:mincloset/src/domain/models/notification_settings.dart';
import 'package:mincloset/src/domain/repositories/notification_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsRepositoryImpl implements INotificationSettingsRepository {
  final SharedPreferences _prefs;

  // Các key để lưu vào SharedPreferences
  static const _masterKey = 'notification_master_enabled';
  static const _morningKey = 'notification_morning_enabled';
  static const _eveningKey = 'notification_evening_enabled';

  NotificationSettingsRepositoryImpl(this._prefs);

  @override
  Future<NotificationSettings> getSettings() async {
    final isMasterEnabled = _prefs.getBool(_masterKey) ?? true;
    final isMorningEnabled = _prefs.getBool(_morningKey) ?? true;
    final isEveningEnabled = _prefs.getBool(_eveningKey) ?? true;

    return NotificationSettings(
      isMasterEnabled: isMasterEnabled,
      isMorningReminderEnabled: isMorningEnabled,
      isEveningReminderEnabled: isEveningEnabled,
    );
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    await _prefs.setBool(_masterKey, settings.isMasterEnabled);
    await _prefs.setBool(_morningKey, settings.isMorningReminderEnabled);
    await _prefs.setBool(_eveningKey, settings.isEveningReminderEnabled);
  }
}