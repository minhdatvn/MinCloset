// lib/src/providers/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/src/data/repositories/notification_settings_repository_impl.dart';
import 'package:mincloset/src/domain/models/notification_settings.dart';
import 'package:mincloset/src/domain/repositories/notification_settings_repository.dart';
import 'package:mincloset/src/services/local_notification_service.dart';

// 1. Provider cho Notification Service (đã có sẵn, chỉ cần gọi lại)
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});

// 2. Provider cho Repository
final notificationSettingsRepositoryProvider =
    Provider<INotificationSettingsRepository>((ref) {
  // Lấy SharedPreferences từ một provider chung đã có
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    // Trường hợp này hiếm khi xảy ra nếu app được khởi tạo đúng cách
    throw Exception("SharedPreferences not initialized for NotificationSettingsRepository");
  }
  return NotificationSettingsRepositoryImpl(prefs);
});

// 3. Provider chính để quản lý State và Logic
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier(ref);
});

// 4. Lớp Notifier để xử lý logic nghiệp vụ
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final Ref _ref;
  late final INotificationSettingsRepository _repository;
  late final LocalNotificationService _service;

  NotificationSettingsNotifier(this._ref) : super(const NotificationSettings()) {
    // Đọc các dependency từ Ref
    _repository = _ref.read(notificationSettingsRepositoryProvider);
    _service = _ref.read(localNotificationServiceProvider);
    // Tải cài đặt đã lưu ngay khi Notifier được tạo
    _loadSettings();
  }

  /// Tải trạng thái cài đặt từ bộ nhớ (SharedPreferences)
  Future<void> _loadSettings() async {
    state = await _repository.getSettings();
    // Sau khi tải, đồng bộ lại lịch thông báo
    _rescheduleNotifications();
  }

  /// Cập nhật cài đặt Bật/Tắt chính
  Future<void> updateMaster(bool isEnabled) async {
    // Cập nhật state ngay lập tức để UI thay đổi
    state = state.copyWith(isEnabled: isEnabled);
    // Lưu cài đặt mới vào bộ nhớ
    await _repository.saveSettings(state);
    // Đồng bộ lại lịch thông báo
    _rescheduleNotifications();
  }

  /// Hủy tất cả thông báo cũ và đặt lại lịch mới dựa trên state hiện tại
  void _rescheduleNotifications() {
    _service.cancelAllNotifications();
    if (state.isEnabled) {
      // Nếu người dùng bật thông báo, lên lịch cho thông báo hàng ngày
      _service.scheduleDailyReminder();
    }
  }
}