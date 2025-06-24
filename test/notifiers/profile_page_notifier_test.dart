// test/notifiers/profile_page_notifier_test.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- CÁC LỚP MOCK KHÔNG THAY ĐỔI ---
class MockClosetRepository extends Mock implements ClosetRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockOutfitRepository extends Mock implements OutfitRepository {}

void main() {
  late ProviderContainer container;
  late MockClosetRepository mockClosetRepo;
  late MockClothingItemRepository mockClothingItemRepo;
  late MockOutfitRepository mockOutfitRepo;

  final tClosets = [Closet(id: 'c1', name: 'Tủ đồ 1')];
  final tOutfits = [const Outfit(id: 'o1', name: 'Outfit 1', imagePath: 'p1', itemIds: 'i1')];
  final tItems = [
    const ClothingItem(id: 'i1', name: 'Áo đỏ', category: 'Áo > Áo thun', color: 'Đỏ', imagePath: 'p1', closetId: 'c1', season: 'Hạ', occasion: 'Đi chơi'),
    const ClothingItem(id: 'i2', name: 'Quần xanh', category: 'Quần > Quần jeans', color: 'Xanh', imagePath: 'p2', closetId: 'c1', season: 'Thu,Hạ', occasion: 'Hằng ngày'),
    const ClothingItem(id: 'i3', name: 'Áo khoác đỏ', category: 'Áo khoác', color: 'Đỏ', imagePath: 'p3', closetId: 'c1', season: 'Đông', occasion: 'Đi làm'),
  ];
  
  // <<< SỬA ĐỔI: Chuyển toàn bộ mock vào setUp >>>
  setUp(() {
    mockClosetRepo = MockClosetRepository();
    mockClothingItemRepo = MockClothingItemRepository();
    mockOutfitRepo = MockOutfitRepository();

    // 1. Giả lập SharedPreferences
    SharedPreferences.setMockInitialValues({
      'user_name': 'Minh Dat',
      'city_mode': 'manual',
      'manual_city_name': 'Hanoi',
    });

    // 2. Giả lập kết quả trả về từ các mock repository
    when(() => mockClosetRepo.getClosets()).thenAnswer((_) async => tClosets);
    when(() => mockOutfitRepo.getOutfits()).thenAnswer((_) async => tOutfits);
    when(() => mockClothingItemRepo.getAllItems()).thenAnswer((_) async => tItems);

    // 3. Khởi tạo ProviderContainer sau khi đã thiết lập xong các mock
    container = ProviderContainer(
      overrides: [
        closetRepositoryProvider.overrideWithValue(mockClosetRepo),
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepo),
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfilePageNotifier', () {
    // <<< SỬA LẠI HOÀN TOÀN BÀI TEST NÀY >>>
    test('khi khởi tạo, nên tự động tải dữ liệu và tính toán thống kê chính xác', () async {
      // ARRANGE
      // Notifier được tạo và `loadInitialData` được gọi tự động trong `setUp`.
      // Chúng ta cần một cơ chế để đợi cho `loadInitialData` (là một Future) hoàn thành.
      final completer = Completer<void>();
      
      // Lắng nghe sự thay đổi của state. Khi state chuyển từ loading=true sang loading=false,
      // nghĩa là quá trình tải đã xong.
      container.listen(
        profileProvider,
        (previous, next) {
          if (previous?.isLoading == true && next.isLoading == false) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
        fireImmediately: true, // fireImmediately để kiểm tra cả trạng thái ban đầu
      );

      // ACT
      // Kích hoạt việc tạo notifier. Dòng này sẽ bắt đầu quá trình tải dữ liệu.
      container.read(profileProvider.notifier);
      // Đợi cho đến khi completer báo hiệu đã tải xong
      await completer.future;

      // ASSERT
      final state = container.read(profileProvider);

      // Kiểm tra các giá trị được tải
      expect(state.userName, 'Minh Dat');
      expect(state.manualCity, 'Hanoi');
      expect(state.totalItems, tItems.length);
      expect(state.totalClosets, tClosets.length);
      expect(state.totalOutfits, tOutfits.length);

      // Kiểm tra logic tính toán thống kê
      expect(state.colorDistribution, {'Đỏ': 2, 'Xanh': 1});
      expect(state.categoryDistribution, {'Áo': 1, 'Quần': 1, 'Áo khoác': 1});
      expect(state.seasonDistribution, {'Hạ': 2, 'Thu': 1, 'Đông': 1});
      expect(state.occasionDistribution, {'Đi chơi': 1, 'Hằng ngày': 1, 'Đi làm': 1});

      // Đảm bảo không có lỗi
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);

      // Xác minh các repository đã được gọi
      verify(() => mockClothingItemRepo.getAllItems()).called(1);
      verify(() => mockClosetRepo.getClosets()).called(1);
      verify(() => mockOutfitRepo.getOutfits()).called(1);
    });
  });
}