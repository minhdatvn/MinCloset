// lib/src/data/repositories/notification_settings_repository_impl.dart

import 'package:mincloset/src/domain/models/notification_settings.dart';
import 'package:mincloset/src/domain/repositories/notification_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsRepositoryImpl implements INotificationSettingsRepository {
  final SharedPreferences _prefs;

  // Key để lưu vào SharedPreferences
  static const _masterKey = 'notification_master_enabled';

  NotificationSettingsRepositoryImpl(this._prefs);

  @override
  Future<NotificationSettings> getSettings() async {
    // Đọc giá trị, nếu không có thì mặc định là true
    final isEnabled = _prefs.getBool(_masterKey) ?? true;
    return NotificationSettings(isEnabled: isEnabled);
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    await _prefs.setBool(_masterKey, settings.isEnabled);
  }
}