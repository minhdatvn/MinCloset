// lib/src/domain/repositories/notification_settings_repository.dart

import 'package:mincloset/src/domain/models/notification_settings.dart';

abstract class INotificationSettingsRepository {
  Future<NotificationSettings> getSettings();
  Future<void> saveSettings(NotificationSettings settings);
}