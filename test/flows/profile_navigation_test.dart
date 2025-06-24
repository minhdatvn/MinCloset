// test/flows/profile_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mincloset/screens/pages/home_page.dart';
import 'package:mincloset/states/home_page_state.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CÁC LỚP MOCK VÀ FAKE ---
class MockClosetRepository extends Mock implements ClosetRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockOutfitRepository extends Mock implements OutfitRepository {}

// Tạo một Notifier giả cho HomePage, nó không làm gì cả, chỉ giữ state rỗng
class FakeHomeNotifier extends StateNotifier<HomePageState> implements HomePageNotifier {
  FakeHomeNotifier() : super(const HomePageState());
  @override
  Future<void> getNewSuggestion() async {}
}

// Tạo một Notifier giả cho ProfilePage để kiểm soát hoàn toàn môi trường test
class FakeProfileNotifier extends StateNotifier<ProfilePageState> implements ProfilePageNotifier {
  // Trạng thái ban đầu có tên người dùng để test có thể tìm thấy
  FakeProfileNotifier() : super(const ProfilePageState(isLoading: false, userName: 'MinCloset user'));

  @override
  Future<void> loadInitialData() async {
    // Không làm gì trong bản giả này
  }
  // Các hàm khác không cần thiết cho bài test này
  @override
  Future<void> updateAvatar() async {}
  @override
  Future<void> updateCityPreference(mode, suggestion) async {}
  @override
  Future<void> updateProfileInfo(data) async {}
}


void main() {
  setUp(() {
    // Không cần mock repository ở đây nữa vì chúng ta dùng Notifier giả
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Trang Profile phải tải lại đúng sau khi điều hướng đi và quay lại', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Ghi đè các notifier thật bằng các notifier giả
          homeProvider.overrideWith((ref) => FakeHomeNotifier()),
          profileProvider.overrideWith((ref) => FakeProfileNotifier()),
          // Vẫn cần provider này cho HomePage
          recentItemsProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Điều hướng đến trang Profile lần đầu
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Kiểm tra trang Profile
    expect(find.text('MinCloset user'), findsOneWidget, reason: 'Nội dung Profile phải hiển thị ở lần truy cập đầu tiên');
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Điều hướng sang tab Home
    await tester.tap(find.byIcon(Icons.home_filled));
    await tester.pumpAndSettle();

    // Kiểm chứng: Đảm bảo đã chuyển sang trang Home
    expect(find.text('Outfit studio'), findsOneWidget);

    // Quay lại trang Profile
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Kiểm tra lại trang Profile
    expect(find.text('MinCloset user'), findsOneWidget, reason: 'Nội dung Profile phải hiển thị lại sau khi quay về');
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'Không được có vòng xoay loading sau khi quay về trang Profile');
  });
}