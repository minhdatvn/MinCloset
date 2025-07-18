// integration_test/app_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mincloset/main.dart'; // Import widget App chính của bạn
import 'package:mincloset/providers/flow_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Đảm bảo binding của Integration Test được khởi tạo
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow Test', () {
    testWidgets('Tạo tủ đồ mới thành công', (WidgetTester tester) async {
      // --- PHẦN THIẾT LẬP (ARRANGE) ---

      // Để đảm bảo mỗi lần chạy test đều sạch sẽ như lần đầu cài app,
      // chúng ta sẽ xóa dữ liệu SharedPreferences cũ.
      SharedPreferences.setMockInitialValues({
        // Giả lập người dùng đã hoàn thành onboarding và xem màn hình quyền
        'has_completed_onboarding': true,
        'has_seen_permissions_screen': true,
      });

      final prefs = await SharedPreferences.getInstance();

      // Khởi chạy ứng dụng
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
             // Cung cấp SharedPreferences đã được mock cho ứng dụng
             sharedPreferencesProvider.overrideWithValue(prefs),
             // Giả lập các trạng thái flow để vào thẳng màn hình chính
             onboardingCompletedProvider.overrideWith((ref) => StateController(true)),
             permissionsSeenProvider.overrideWith((ref) => StateController(true)),
             initialScreenProvider.overrideWithValue(const MainScreen()),
          ],
          child: const MinClosetApp(), // Chạy widget App chính
        ),
      );
      
      // Chờ ứng dụng ổn định (ví dụ: chờ các animation, future hoàn tất)
      await tester.pumpAndSettle();

      // --- PHẦN HÀNH ĐỘNG (ACT) ---

      // 1. Tìm và nhấn vào tab "Closets" (Tủ đồ)
      // Chúng ta tìm widget bằng Icon của nó
      final closetsTabFinder = find.byIcon(Icons.door_sliding_outlined);
      expect(closetsTabFinder, findsOneWidget, reason: 'Không tìm thấy tab Tủ đồ');
      await tester.tap(closetsTabFinder);
      await tester.pumpAndSettle();

      // 2. Tìm và nhấn vào sub-tab "By Closet" (Theo Tủ đồ)
      final byClosetTabFinder = find.text('By Closet');
      expect(byClosetTabFinder, findsOneWidget, reason: 'Không tìm thấy sub-tab "By Closet"');
      await tester.tap(byClosetTabFinder);
      await tester.pumpAndSettle();

      // 3. Tìm và nhấn nút "Add new closet" (Thêm tủ đồ mới)
      final addClosetButtonFinder = find.text('Add new closet');
      expect(addClosetButtonFinder, findsOneWidget, reason: 'Không tìm thấy nút "Add new closet"');
      await tester.tap(addClosetButtonFinder);
      await tester.pumpAndSettle();

      // 4. Nhập tên cho tủ đồ mới vào TextField
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget, reason: 'Không tìm thấy ô nhập liệu tên tủ đồ');
      await tester.enterText(textFieldFinder, 'Đồ đi làm');
      await tester.pumpAndSettle();

      // 5. Tìm và nhấn nút "Save"
      final saveButtonFinder = find.text('Save');
      expect(saveButtonFinder, findsOneWidget, reason: 'Không tìm thấy nút Save');
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Chờ lâu hơn một chút để CSDL cập nhật

      // --- PHẦN KIỂM TRA (ASSERT) ---

      // 6. Kiểm tra xem tủ đồ "Đồ đi làm" có thực sự xuất hiện trên màn hình không
      final newClosetFinder = find.text('Đồ đi làm');
      expect(newClosetFinder, findsOneWidget, reason: 'Tủ đồ mới "Đồ đi làm" không xuất hiện sau khi lưu');
    });
  });
}