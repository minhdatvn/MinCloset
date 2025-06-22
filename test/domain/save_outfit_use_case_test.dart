// test/domain/save_outfit_use_case_test.dart

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/use_cases/save_outfit_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mocktail/mocktail.dart';

// --- Các lớp Mock và Fake không thay đổi ---
class MockOutfitRepository extends Mock implements OutfitRepository {}
class FakeOutfit extends Fake implements Outfit {}

void main() {
  // --- PHẦN SỬA LỖI QUAN TRỌNG ---
  // Đảm bảo rằng binding của Flutter test đã được khởi tạo.
  // Điều này cần thiết để truy cập `TestDefaultBinaryMessengerBinding`.
  TestWidgetsFlutterBinding.ensureInitialized();

  late SaveOutfitUseCase useCase;
  late MockOutfitRepository mockOutfitRepository;

  // Định nghĩa kênh platform mà chúng ta muốn mock
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    registerFallbackValue(FakeOutfit());
  });

  setUp(() {
    mockOutfitRepository = MockOutfitRepository();
    useCase = SaveOutfitUseCase(mockOutfitRepository);

    // --- ĐÂY LÀ CÁCH MOCK MỚI VÀ CHÍNH XÁC ---
    // Chúng ta sử dụng `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger`
    // để đăng ký một "trình xử lý cuộc gọi giả" (mock call handler) cho kênh đã định nghĩa.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        // Tạo một đường dẫn tạm thời và giả để trả về
        final tempDir = await Directory.systemTemp.createTemp('test_app_doc_dir');
        return tempDir.path;
      }
      return null;
    });
  });

  // Thêm tearDown để dọn dẹp mock handler sau mỗi bài test
  // Điều này ngăn chặn việc handler của test này ảnh hưởng đến các test khác.
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

    test('Nên lưu ảnh và gọi insertOutfit trên repository với dữ liệu chính xác', () async {
      // Sắp xếp
      when(() => mockOutfitRepository.insertOutfit(any())).thenAnswer((_) async => Future.value());

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

      expect(savedOutfit.name, tName);
      expect(savedOutfit.isFixed, tIsFixed);
      expect(savedOutfit.itemIds, 'item1,item2');
      // Kiểm tra xem file ảnh có được tạo ra trong thư mục tạm không
      final file = File(savedOutfit.imagePath);
      expect(await file.exists(), isTrue);
      // Dọn dẹp file
      await file.delete();
    });
  });
}