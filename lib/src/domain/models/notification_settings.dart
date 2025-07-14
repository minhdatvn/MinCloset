// lib/src/domain/models/notification_settings.dart

import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool isEnabled;

  const NotificationSettings({
    this.isEnabled = true, // Mặc định là bật
  });

  NotificationSettings copyWith({
    bool? isEnabled,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object> get props => [isEnabled];
}