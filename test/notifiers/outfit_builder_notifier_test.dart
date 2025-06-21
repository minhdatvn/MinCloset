// test/notifiers/outfit_builder_notifier_test.dart

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/providers.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/notifiers/outfit_builder_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';

// 1. Tạo các lớp Mock
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class MockOutfitRepository extends Mock implements OutfitRepository {}
class MockSaveOutfitUseCase extends Mock implements SaveOutfitUseCase {}

void main() {
  late ProviderContainer container;
  late MockClothingItemRepository mockClothingItemRepo;
  late MockOutfitRepository mockOutfitRepo;
  late MockSaveOutfitUseCase mockSaveOutfitUseCase;

  // <<< SỬA LỖI 2: THÊM HÀM `setUpAll` ĐỂ ĐĂNG KÝ FALLBACK VALUE >>>
  setUpAll(() {
    // Đăng ký giá trị dự phòng cho Uint8List để mocktail có thể xử lý
    registerFallbackValue(Uint8List(0));
    // Đăng ký cho Map<String, ClothingItem>
    registerFallbackValue(<String, ClothingItem>{});
  });

  // Dữ liệu mẫu
  const item1 = ClothingItem(id: 'id1', name: 'Áo thun', category: 'Áo', color: 'Trắng', imagePath: 'path1', closetId: 'c1');
  const item2 = ClothingItem(id: 'id2', name: 'Quần jeans', category: 'Quần', color: 'Xanh', imagePath: 'path2', closetId: 'c1');
  const item3 = ClothingItem(id: 'id3', name: 'Giày sneaker', category: 'Giày', color: 'Đen', imagePath: 'path3', closetId: 'c1');

  // Dùng `setUp` để khởi tạo cho mỗi bài test
  setUp(() {
    mockClothingItemRepo = MockClothingItemRepository();
    mockOutfitRepo = MockOutfitRepository();
    mockSaveOutfitUseCase = MockSaveOutfitUseCase();

    // Giả lập rằng khi notifier khởi tạo, nó sẽ tải thành công danh sách item
    when(() => mockClothingItemRepo.getAllItems()).thenAnswer((_) async => [item1, item2, item3]);

    container = ProviderContainer(
      overrides: [
        clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepo),
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepo),
        saveOutfitUseCaseProvider.overrideWithValue(mockSaveOutfitUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('OutfitBuilderNotifier Tests', () {
    test('Nên tải danh sách vật phẩm khi khởi tạo', () {
      // Act: Chỉ cần đọc provider là đủ để kích hoạt hàm khởi tạo
      container.read(outfitBuilderProvider);

      // Assert
      // Phải đợi một chút để các hàm async trong constructor chạy xong
      // Chúng ta có thể verify ngay lập tức vì `when` ở trên trả về kết quả ngay
      verify(() => mockClothingItemRepo.getAllItems()).called(1);
    });

    test('addItemToCanvas nên thêm một vật phẩm vào canvas', () {
      // Arrange
      final notifier = container.read(outfitBuilderProvider.notifier);

      // Act
      notifier.addItemToCanvas(item1);

      // Assert
      final state = container.read(outfitBuilderProvider);
      expect(state.itemsOnCanvas.length, 1);
      expect(state.itemsOnCanvas.values.first, item1);
    });

    test('deleteSticker nên xóa một vật phẩm khỏi canvas', () {
      // Arrange
      final notifier = container.read(outfitBuilderProvider.notifier);
      notifier.addItemToCanvas(item1); // Thêm một item trước
      final stickerId = container.read(outfitBuilderProvider).itemsOnCanvas.keys.first;

      // Act
      notifier.deleteSticker(stickerId);

      // Assert
      expect(container.read(outfitBuilderProvider).itemsOnCanvas, isEmpty);
    });

    test('saveOutfit nên báo lỗi khi lưu bộ đồ cố định bị xung đột', () async {
      // Arrange
      // 1. Giả lập một bộ đồ cố định đã tồn tại trong CSDL chứa 'item2'
      final existingFixedOutfit = Outfit(id: 'outfit1', name: 'Đồng phục đi học', imagePath: '', itemIds: 'id2,id4', isFixed: true);
      when(() => mockOutfitRepo.getFixedOutfits()).thenAnswer((_) async => [existingFixedOutfit]);

      // 2. Giả lập hàm getItemById để có thể lấy thông tin item xung đột
      when(() => mockClothingItemRepo.getItemById('id2')).thenAnswer((_) async => item2);
      
      final notifier = container.read(outfitBuilderProvider.notifier);
      
      // 3. Thêm các item vào canvas, trong đó có 'item2' gây xung đột
      notifier.addItemToCanvas(item1);
      notifier.addItemToCanvas(item2); 

      // Act
      // Cố gắng lưu bộ đồ mới dưới dạng "cố định"
      await notifier.saveOutfit('Bộ đồ mới', true, Uint8List(0));

      // Assert
      final state = container.read(outfitBuilderProvider);
      expect(state.isSaving, isFalse);
      expect(state.saveSuccess, isFalse);
      // Kiểm tra thông báo lỗi chứa tên của vật phẩm xung đột
      expect(state.errorMessage, contains("'Quần jeans' đã thuộc một Bộ đồ cố định khác"));
      
      // <<< SỬA LỖI 1: Cung cấp đúng các tham số cho `any` >>>
      // Xác minh rằng UseCase lưu trữ không bao giờ được gọi
      verifyNever(() => mockSaveOutfitUseCase.execute(
        name: any(named: 'name'),
        isFixed: any(named: 'isFixed'),
        itemsOnCanvas: any(named: 'itemsOnCanvas'),
        capturedImage: any(named: 'capturedImage'),
      ));
    });
  });
}