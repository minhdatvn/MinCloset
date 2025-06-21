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

// 1. TẠO CÁC LỚP MOCK
class MockClosetRepository extends Mock implements ClosetRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockOutfitRepository extends Mock implements OutfitRepository {}

void main() {
  // 2. KHAI BÁO BIẾN
  late ProviderContainer container;
  late MockClosetRepository mockClosetRepo;
  late MockClothingItemRepository mockItemRepo;
  late MockOutfitRepository mockOutfitRepo;

  // 3. HÀM `setUp`
  setUp(() {
    mockClosetRepo = MockClosetRepository();
    mockItemRepo = MockClothingItemRepository();
    mockOutfitRepo = MockOutfitRepository();
    
    // Tạo container và override các provider repository
    container = ProviderContainer(
      overrides: [
        closetRepositoryProvider.overrideWithValue(mockClosetRepo),
        clothingItemRepositoryProvider.overrideWithValue(mockItemRepo),
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // 4. DỮ LIỆU GIẢ
  // Dữ liệu giả cho SharedPreferences
  final mockUserPrefs = {
    'user_name': 'Test User',
    'user_gender': 'Nam',
    'city_mode': 'manual',
    'manual_city_name': 'Hanoi',
  };
  
  // Dữ liệu giả cho các repository
  final mockClosets = [Closet(id: 'c1', name: 'Tủ đồ hè')];
  final mockOutfits = [const Outfit(id: 'o1', name: 'Đi biển', imagePath: 'p1', itemIds: 'i1,i2')];
  final mockItems = [
    const ClothingItem(id: 'i1', name: 'Áo thun', category: 'Áo > Áo thun', color: 'Trắng, Xanh', imagePath: 'p1', closetId: 'c1', season: 'Hạ', occasion: 'Đi biển'),
    const ClothingItem(id: 'i2', name: 'Quần short', category: 'Quần > Quần short', color: 'Xanh', imagePath: 'p2', closetId: 'c1', season: 'Hạ', occasion: 'Du lịch'),
    const ClothingItem(id: 'i3', name: 'Áo khoác', category: 'Áo khoác > Jackets', color: 'Đen', imagePath: 'p3', closetId: 'c1', season: 'Đông', occasion: 'Đi làm'),
  ];

  group('ProfilePageNotifier', () {
    test('loadInitialData nên tải, tính toán và cập nhật state chính xác', () async {
      // Sắp xếp (Arrange)
      // 1. Giả lập SharedPreferences có chứa dữ liệu người dùng
      SharedPreferences.setMockInitialValues(mockUserPrefs);

      // 2. Giả lập các repository trả về dữ liệu giả đã chuẩn bị
      when(() => mockClosetRepo.getClosets()).thenAnswer((_) async => mockClosets);
      when(() => mockItemRepo.getAllItems()).thenAnswer((_) async => mockItems);
      when(() => mockOutfitRepo.getOutfits()).thenAnswer((_) async => mockOutfits);

      // Hành động (Act)
      // Lấy ra notifier và gọi hàm cần test
      final notifier = container.read(profileProvider.notifier);
      await notifier.loadInitialData();

      // Kiểm chứng (Assert)
      final state = container.read(profileProvider);

      // a. Kiểm tra thông tin cá nhân từ SharedPreferences
      expect(state.isLoading, isFalse);
      expect(state.userName, 'Test User');
      expect(state.gender, 'Nam');
      expect(state.manualCity, 'Hanoi');

      // b. Kiểm tra các số liệu thống kê tổng quan
      expect(state.totalItems, 3);
      expect(state.totalClosets, 1);
      expect(state.totalOutfits, 1);

      // c. Kiểm tra các dữ liệu phân phối đã được tính toán đúng
      // Phân phối màu: Xanh (2), Trắng (1), Đen (1)
      expect(state.colorDistribution['Xanh'], 2);
      expect(state.colorDistribution['Trắng'], 1);
      expect(state.colorDistribution['Đen'], 1);

      // Phân phối danh mục chính: Áo (1), Quần (1), Áo khoác (1)
      expect(state.categoryDistribution['Áo'], 1);
      expect(state.categoryDistribution['Quần'], 1);
      expect(state.categoryDistribution['Áo khoác'], 1);
      
      // Phân phối mùa: Hạ (2), Đông (1)
      expect(state.seasonDistribution['Hạ'], 2);
      expect(state.seasonDistribution['Đông'], 1);
      
      // Phân phối mục đích: Đi biển (1), Du lịch (1), Đi làm (1)
      expect(state.occasionDistribution['Đi biển'], 1);
      expect(state.occasionDistribution['Du lịch'], 1);
      expect(state.occasionDistribution['Đi làm'], 1);
    });
  });
}