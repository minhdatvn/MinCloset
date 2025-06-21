// test/notifiers/outfit_detail_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_detail_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';

// 1. TẠO CÁC LỚP MOCK CHO DEPENDENCIES
class MockOutfitRepository extends Mock implements OutfitRepository {}
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}

// 2. TẠO CÁC LỚP FAKE
class FakeOutfit extends Fake implements Outfit {}

void main() {
  // 3. ĐĂNG KÝ FALLBACK VALUE
  setUpAll(() {
    registerFallbackValue(FakeOutfit());
  });

  // 4. KHAI BÁO BIẾN
  late ProviderContainer container;
  late MockOutfitRepository mockOutfitRepository;
  late MockClothingItemRepository mockClothingItemRepository;

  // Dữ liệu giả
  const initialOutfit = Outfit(
    id: 'outfit1',
    name: 'Đi Đà Lạt',
    imagePath: 'path/1.png',
    itemIds: 'itemA,itemB', // Vật phẩm A và B
    isFixed: false,
  );

  // 5. HÀM `setUp`
  // Chạy trước mỗi test để tạo môi trường sạch
  setUp(() {
    mockOutfitRepository = MockOutfitRepository();
    mockClothingItemRepository = MockClothingItemRepository();
    
    // Tạo ProviderContainer và override các provider phụ thuộc bằng mock
    container = ProviderContainer(
      overrides: [
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepository),
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepository),
      ],
    );
  });

  // Dọn dẹp container sau mỗi test
  tearDown(() {
    container.dispose();
  });

  // 6. VIẾT CÁC TEST CASE
  group('OutfitDetailNotifier', () {
    test('updateName - nên gọi updateOutfit trong repository và cập nhật state', () async {
      // Sắp xếp (Arrange)
      const newName = 'Đi Vũng Tàu';
      // Giả lập hàm updateOutfit không làm gì cả
      when(() => mockOutfitRepository.updateOutfit(any())).thenAnswer((_) async {});

      // Lấy ra notifier để thực hiện hành động
      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);

      // Hành động (Act)
      await notifier.updateName(newName);

      // Kiểm chứng (Assert)
      // Kiểm tra xem state của notifier đã được cập nhật đúng tên mới chưa
      expect(container.read(outfitDetailProvider(initialOutfit)).name, newName);

      // Xác minh rằng hàm updateOutfit của repository đã được gọi 1 lần
      final captured = verify(() => mockOutfitRepository.updateOutfit(captureAny())).captured;
      // Kiểm tra xem outfit được truyền vào có đúng là tên mới không
      expect((captured.first as Outfit).name, newName);
    });

    test('toggleIsFixed - nên thành công khi không có xung đột', () async {
      // Arrange
      // Giả lập rằng không có bộ đồ cố định nào khác tồn tại
      when(() => mockOutfitRepository.getFixedOutfits()).thenAnswer((_) async => []);
      when(() => mockOutfitRepository.updateOutfit(any())).thenAnswer((_) async {});

      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);

      // Act
      final result = await notifier.toggleIsFixed(true);

      // Assert
      // Kết quả trả về phải là null (không có lỗi)
      expect(result, isNull);
      // Trạng thái isFixed của notifier phải được cập nhật thành true
      expect(container.read(outfitDetailProvider(initialOutfit)).isFixed, isTrue);
      // Hàm updateOutfit phải được gọi
      verify(() => mockOutfitRepository.updateOutfit(any())).called(1);
    });

    test('toggleIsFixed - nên trả về lỗi khi vật phẩm đã thuộc bộ đồ cố định khác', () async {
      // Arrange
      // Giả lập có một bộ đồ cố định khác chứa 'itemB'
      final conflictingOutfit = const Outfit(
        id: 'outfit2',
        name: 'Đồng phục công ty',
        imagePath: 'path/2.png',
        itemIds: 'itemB,itemC', // Xung đột tại itemB
        isFixed: true,
      );
      when(() => mockOutfitRepository.getFixedOutfits()).thenAnswer((_) async => [conflictingOutfit]);

      // Giả lập hàm lấy thông tin của vật phẩm xung đột để hiển thị tên trong thông báo lỗi
      const conflictingItem = ClothingItem(id: 'itemB', name: 'Áo sơ mi trắng', category: 'Áo', color: 'Trắng', imagePath: 'path/b', closetId: 'c1');
      when(() => mockClothingItemRepository.getItemById('itemB')).thenAnswer((_) async => conflictingItem);

      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);

      // Act
      final result = await notifier.toggleIsFixed(true);

      // Assert
      // Kết quả trả về phải là một chuỗi lỗi chứa tên vật phẩm
      expect(result, isNotNull);
      expect(result, contains("'Áo sơ mi trắng' đã thuộc một Bộ đồ cố định khác"));
      
      // Trạng thái isFixed của notifier KHÔNG được thay đổi
      expect(container.read(outfitDetailProvider(initialOutfit)).isFixed, isFalse);
      
      // Hàm updateOutfit KHÔNG được gọi
      verifyNever(() => mockOutfitRepository.updateOutfit(any()));
    });

    test('deleteOutfit - nên gọi deleteOutfit trong repository', () async {
      // Arrange
      when(() => mockOutfitRepository.deleteOutfit(any())).thenAnswer((_) async {});

      final notifier = container.read(outfitDetailProvider(initialOutfit).notifier);

      // Act
      await notifier.deleteOutfit();

      // Assert
      // Xác minh rằng hàm deleteOutfit được gọi 1 lần với đúng ID
      verify(() => mockOutfitRepository.deleteOutfit(initialOutfit.id)).called(1);
    });
  });
}