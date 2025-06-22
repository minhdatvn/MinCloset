// test/notifiers/profile_page_notifier_test.dart

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

// --- BƯỚC 1: TẠO CÁC LỚP MOCK ---
class MockClosetRepository extends Mock implements ClosetRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockOutfitRepository extends Mock implements OutfitRepository {}

void main() {
  // Khai báo các biến mock và ProviderContainer
  late MockClosetRepository mockClosetRepo;
  late MockClothingItemRepository mockClothingItemRepo;
  late MockOutfitRepository mockOutfitRepo;
  late ProviderContainer container;

  // Dữ liệu mẫu để giả lập kết quả trả về từ các repository
  final tClosets = [Closet(id: 'c1', name: 'Tủ đồ 1')];
  final tOutfits = [const Outfit(id: 'o1', name: 'Outfit 1', imagePath: 'p1', itemIds: 'i1')];
  final tItems = [
    const ClothingItem(id: 'i1', name: 'Áo đỏ', category: 'Áo > Áo thun', color: 'Đỏ', imagePath: 'p1', closetId: 'c1', season: 'Hạ', occasion: 'Đi chơi'),
    const ClothingItem(id: 'i2', name: 'Quần xanh', category: 'Quần > Quần jeans', color: 'Xanh', imagePath: 'p2', closetId: 'c1', season: 'Thu,Hạ', occasion: 'Hằng ngày'),
    const ClothingItem(id: 'i3', name: 'Áo khoác đỏ', category: 'Áo khoác', color: 'Đỏ', imagePath: 'p3', closetId: 'c1', season: 'Đông', occasion: 'Đi làm'),
  ];

  // --- BƯỚC 2: HÀM `setUp` ---
  // Hàm này chạy trước mỗi bài test
  setUp(() {
    // Khởi tạo các mock repository
    mockClosetRepo = MockClosetRepository();
    mockClothingItemRepo = MockClothingItemRepository();
    mockOutfitRepo = MockOutfitRepository();

    // Khởi tạo ProviderContainer và GHI ĐÈ các provider thật bằng các mock
    container = ProviderContainer(
      overrides: [
        closetRepositoryProvider.overrideWithValue(mockClosetRepo),
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepo),
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepo),
      ],
    );
  });

  // Dọn dẹp container sau mỗi bài test
  tearDown(() {
    container.dispose();
  });


  group('ProfilePageNotifier', () {
    test('loadInitialData - nên tải dữ liệu và tính toán thống kê chính xác', () async {
      // --- SẮP XẾP (ARRANGE) ---

      // 1. Giả lập dữ liệu trong SharedPreferences
      SharedPreferences.setMockInitialValues({
        'user_name': 'Minh Dat',
        'city_mode': 'manual',
        'manual_city_name': 'Hanoi',
      });

      // 2. Giả lập kết quả trả về từ các mock repository
      when(() => mockClosetRepo.getClosets()).thenAnswer((_) async => tClosets);
      when(() => mockOutfitRepo.getOutfits()).thenAnswer((_) async => tOutfits);
      when(() => mockClothingItemRepo.getAllItems()).thenAnswer((_) async => tItems);
      
      // Lấy ra notifier từ container
      final notifier = container.read(profileProvider.notifier);

      // --- HÀNH ĐỘNG (ACT) ---
      await notifier.loadInitialData();

      // --- KIỂM CHỨNG (ASSERT) ---
      // Lấy ra trạng thái cuối cùng của notifier
      final state = container.read(profileProvider);

      // Kiểm tra các giá trị được tải từ SharedPreferences
      expect(state.userName, 'Minh Dat');
      expect(state.manualCity, 'Hanoi');
      
      // Kiểm tra các giá trị tổng quan
      expect(state.totalItems, tItems.length); // 3
      expect(state.totalClosets, tClosets.length); // 1
      expect(state.totalOutfits, tOutfits.length); // 1

      // Kiểm tra logic tính toán thống kê (quan trọng)
      // Phân phối màu: Đỏ (2), Xanh (1)
      expect(state.colorDistribution, {'Đỏ': 2, 'Xanh': 1});
      // Phân phối danh mục chính: Áo (1), Quần (1), Áo khoác (1)
      expect(state.categoryDistribution, {'Áo': 1, 'Quần': 1, 'Áo khoác': 1});
      // Phân phối mùa: Hạ (2), Thu (1), Đông (1)
      expect(state.seasonDistribution, {'Hạ': 2, 'Thu': 1, 'Đông': 1});
      // Phân phối mục đích: Đi chơi (1), Hằng ngày (1), Đi làm (1)
      expect(state.occasionDistribution, {'Đi chơi': 1, 'Hằng ngày': 1, 'Đi làm': 1});

      // Đảm bảo không có lỗi
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);

      // Xác minh các repository đã được gọi
      verify(() => mockClothingItemRepo.getAllItems()).called(1);
      verify(() => mockClosetRepo.getClosets()).called(1);
      verify(() => mockOutfitRepo.getOutfits()).called(1);
    });

    // Bạn có thể viết thêm test cho các hàm khác như updateAvatar, updateProfileInfo...
  });
}