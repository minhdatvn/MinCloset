// test/providers/notification_settings_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/src/domain/models/notification_settings.dart';
import 'package:mincloset/src/domain/repositories/notification_settings_repository.dart';
import 'package:mincloset/src/providers/notification_providers.dart';
import 'package:mincloset/src/services/local_notification_service.dart';
import 'package:mocktail/mocktail.dart';

// Các lớp Mock và Fake không thay đổi
class MockNotificationSettingsRepository extends Mock 
    implements INotificationSettingsRepository {}

class MockLocalNotificationService extends Mock 
    implements LocalNotificationService {}

class FakeNotificationSettings extends Fake implements NotificationSettings {}

void main() {
  late MockNotificationSettingsRepository mockRepository;
  late MockLocalNotificationService mockService;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeNotificationSettings());
  });

  setUp(() {
    mockRepository = MockNotificationSettingsRepository();
    mockService = MockLocalNotificationService();

    // Giả lập các hàm của service không trả về gì (void)
    when(() => mockService.scheduleDailyReminder()).thenAnswer((_) async {});
    when(() => mockService.cancelAllNotifications()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        notificationSettingsRepositoryProvider.overrideWithValue(mockRepository),
        localNotificationServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationSettingsNotifier Tests', () {
    test('Khi khởi tạo và cài đặt là BẬT, notifier sẽ hủy rồi lên lịch thông báo', () async {
      // ARRANGE
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const NotificationSettings(isEnabled: true));

      // ACT
      container.read(notificationSettingsProvider.notifier);
      await Future.delayed(Duration.zero);

      // ASSERT: Sửa lại để phản ánh đúng logic "cancel-then-reschedule"
      // Phải có một chuỗi gọi hàm đúng thứ tự
      verifyInOrder([
        () => mockRepository.getSettings(),
        () => mockService.cancelAllNotifications(), // 1. Hàm hủy được gọi
        () => mockService.scheduleDailyReminder()   // 2. Hàm lên lịch được gọi
      ]);
    });

    test('Khi khởi tạo và cài đặt là TẮT, notifier chỉ hủy thông báo', () async {
      // ARRANGE
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const NotificationSettings(isEnabled: false));

      // ACT
      container.read(notificationSettingsProvider.notifier);
      await Future.delayed(Duration.zero);

      // ASSERT
      verify(() => mockRepository.getSettings()).called(1);
      verify(() => mockService.cancelAllNotifications()).called(1);
      verifyNever(() => mockService.scheduleDailyReminder()); // Hàm lên lịch không được gọi
    });

    test('Khi gọi updateMaster(false), notifier sẽ lưu và hủy thông báo', () async {
      // ARRANGE
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => const NotificationSettings(isEnabled: true));
      when(() => mockRepository.saveSettings(any<NotificationSettings>())).thenAnswer((_) async {});
      
      final notifier = container.read(notificationSettingsProvider.notifier);
      // Chờ cho quá trình khởi tạo hoàn tất (bao gồm cả lần gọi cancelAllNotifications đầu tiên)
      await Future.delayed(Duration.zero); 

      // ACT: Tắt thông báo
      await notifier.updateMaster(false);

      // ASSERT
      expect(container.read(notificationSettingsProvider).isEnabled, isFalse);
      verify(() => mockRepository.saveSettings(const NotificationSettings(isEnabled: false))).called(1);
      // Kiểm tra xem hàm cancel có được gọi TỔNG CỘNG 2 lần không (1 lần lúc khởi tạo, 1 lần lúc update)
      verify(() => mockService.cancelAllNotifications()).called(2);
    });
  });
}