// lib/src/domain/models/notification_settings.dart

import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool isMasterEnabled;
  final bool isMorningReminderEnabled;
  final bool isEveningReminderEnabled;

  const NotificationSettings({
    this.isMasterEnabled = true,
    this.isMorningReminderEnabled = true,
    this.isEveningReminderEnabled = true,
  });

  NotificationSettings copyWith({
    bool? isMasterEnabled,
    bool? isMorningReminderEnabled,
    bool? isEveningReminderEnabled,
  }) {
    return NotificationSettings(
      isMasterEnabled: isMasterEnabled ?? this.isMasterEnabled,
      isMorningReminderEnabled:
          isMorningReminderEnabled ?? this.isMorningReminderEnabled,
      isEveningReminderEnabled:
          isEveningReminderEnabled ?? this.isEveningReminderEnabled,
    );
  }

  @override
  List<Object> get props => [
        isMasterEnabled,
        isMorningReminderEnabled,
        isEveningReminderEnabled,
      ];
}