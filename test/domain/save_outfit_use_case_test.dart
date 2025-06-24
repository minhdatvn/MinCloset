// test/domain/save_outfit_use_case_test.dart

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/helpers/image_helper.dart'; // <<< THÊM IMPORT
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';

// --- CÁC LỚP MOCK ---
class MockOutfitRepository extends Mock implements OutfitRepository {}
class MockImageHelper extends Mock implements ImageHelper {} // <<< THÊM MOCK MỚI
class FakeOutfit extends Fake implements Outfit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SaveOutfitUseCase useCase;
  late MockOutfitRepository mockOutfitRepository;
  late MockImageHelper mockImageHelper; // <<< KHAI BÁO BIẾN MỚI

  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    registerFallbackValue(FakeOutfit());
  });

  setUp(() {
    mockOutfitRepository = MockOutfitRepository();
    mockImageHelper = MockImageHelper(); // <<< KHỞI TẠO MOCK
    
    // <<< SỬA LỖI: Truyền vào 2 tham số >>>
    useCase = SaveOutfitUseCase(mockOutfitRepository, mockImageHelper);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final tempDir = await Directory.systemTemp.createTemp('test_app_doc_dir');
        return tempDir.path;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });


  group('SaveOutfitUseCase', () {
    const tName = 'Bộ đồ đi tiệc';
    const tIsFixed = true;
    final tItemsOnCanvas = {
      'sticker1': const ClothingItem(id: 'item1', name: 'Váy đen', category: 'Váy', color: 'Đen', imagePath: 'path1', closetId: 'c1'),
      'sticker2': const ClothingItem(id: 'item2', name: 'Giày cao gót', category: 'Giày', color: 'Đỏ', imagePath: 'path2', closetId: 'c1'),
    };
    final tCapturedImage = Uint8List.fromList([1, 2, 3]);

    test('Nên lưu ảnh, tạo thumbnail và gọi insertOutfit trên repository', () async {
      // Sắp xếp
      // Giả lập các hàm không trả về gì
      when(() => mockOutfitRepository.insertOutfit(any())).thenAnswer((_) async => Future.value());
      // Giả lập hàm tạo thumbnail trả về một đường dẫn giả
      when(() => mockImageHelper.createThumbnail(any())).thenAnswer((_) async => 'path/to/thumb.jpg');

      // Hành động
      await useCase.execute(
        name: tName,
        isFixed: tIsFixed,
        itemsOnCanvas: tItemsOnCanvas,
        capturedImage: tCapturedImage,
      );

      // Kiểm chứng
      final captured = verify(() => mockOutfitRepository.insertOutfit(captureAny())).captured;
      expect(captured.length, 1);
      final savedOutfit = captured.first as Outfit;

      // Kiểm tra các thuộc tính của outfit đã được lưu
      expect(savedOutfit.name, tName);
      expect(savedOutfit.isFixed, tIsFixed);
      expect(savedOutfit.itemIds, 'item1,item2');
      expect(savedOutfit.thumbnailPath, 'path/to/thumb.jpg'); // Kiểm tra thumbnail path
      
      // Kiểm tra xem file ảnh gốc có được tạo ra không
      final file = File(savedOutfit.imagePath);
      expect(await file.exists(), isTrue);
      await file.delete();
    });
  });
}