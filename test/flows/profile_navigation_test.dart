// test/flows/profile_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/screens/main_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- PHẦN MOCK REPOSITORIES ---
// Chúng ta tạo các phiên bản "giả" của các repository
// để test không cần truy cập vào cơ sở dữ liệu thật.
class MockClosetRepository extends Mock implements ClosetRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockOutfitRepository extends Mock implements OutfitRepository {}

void main() {
  // Khai báo các biến mock
  late MockClosetRepository mockClosetRepo;
  late MockClothingItemRepository mockClothingItemRepo;
  late MockOutfitRepository mockOutfitRepo;

  // `setUp` chạy trước mỗi bài test
  setUp(() {
    // Khởi tạo các mock
    mockClosetRepo = MockClosetRepository();
    mockClothingItemRepo = MockClothingItemRepository();
    mockOutfitRepo = MockOutfitRepository();

    // "Dạy" cho các mock biết phải trả về dữ liệu gì khi được gọi.
    // Ở đây ta trả về các danh sách rỗng để chúng không bị lỗi.
    when(() => mockClosetRepo.getClosets()).thenAnswer((_) async => [Closet(id: 'c1', name: 'Tủ đồ test')]);
    when(() => mockClothingItemRepo.getAllItems()).thenAnswer((_) async => []);
    when(() => mockOutfitRepo.getOutfits()).thenAnswer((_) async => []);
    
    // Giả lập SharedPreferences để tránh lỗi
    SharedPreferences.setMockInitialValues({});
  });

  // Bắt đầu bài test
  testWidgets('Trang Profile phải tải lại đúng sau khi điều hướng đi và quay lại', (tester) async {
    // --- BƯỚC 1: DỰNG ỨNG DỤNG VỚI CÁC REPOSITORY GIẢ ---
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Ghi đè các provider thật bằng các provider giả đã được thiết lập ở trên
          closetRepositoryProvider.overrideWithValue(mockClosetRepo),
          clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepo),
          outfitRepositoryProvider.overrideWithValue(mockOutfitRepo),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );
    // Chờ cho tất cả các frame được render xong
    await tester.pumpAndSettle();

    // --- BƯỚC 2: ĐIỀU HƯỚNG ĐẾN TRANG PROFILE LẦN ĐẦU ---
    // Tìm và nhấn vào biểu tượng của tab Profile
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Kiểm chứng lần 1: Trang Profile phải hiển thị nội dung, ví dụ như tên người dùng mặc định
    // và không có vòng xoay loading.
    expect(find.text('Người dùng MinCloset'), findsOneWidget, reason: 'Nội dung Profile phải hiển thị ở lần truy cập đầu tiên');
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // --- BƯỚC 3: ĐIỀU HƯỚNG SANG TAB KHÁC (ví dụ: HOME) ---
    await tester.tap(find.byIcon(Icons.home_filled));
    await tester.pumpAndSettle();

    // Kiểm chứng: Đảm bảo đã chuyển sang trang Home
    expect(find.text('Xưởng phối đồ'), findsOneWidget);

    // --- BƯỚC 4: QUAY LẠI TRANG PROFILE ---
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // --- KIỂM CHỨNG CUỐI CÙNG (QUAN TRỌNG NHẤT) ---
    // Bài test này sẽ PASS nếu lỗi đã được sửa:
    // Trang Profile phải hiển thị lại nội dung và không có vòng xoay loading.
    expect(find.text('Người dùng MinCloset'), findsOneWidget, reason: 'Nội dung Profile phải hiển thị lại sau khi quay về');
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'Không được có vòng xoay loading sau khi quay về trang Profile');
  });
}