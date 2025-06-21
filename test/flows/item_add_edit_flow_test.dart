// test/flows/item_add_edit_flow_test.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mocktail/mocktail.dart';

// --- CÁC LỚP MOCK VÀ FAKE ---
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class FakeClothingItem extends Fake implements ClothingItem {}

// --- HÀM HELPER TẠO ẢNH GIẢ ---
Future<File> createDummyImage(String fileName) async {
  final directory = Directory('test/temp_test_images');
  final file = File('${directory.path}/$fileName');
  final Uint8List transparentImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ]);
  await file.writeAsBytes(transparentImage);
  return file;
}


void main() {
  // --- THIẾT LẬP MÔI TRƯỜNG TEST ---
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeClothingItem());
    Directory('test/temp_test_images').createSync(recursive: true);
  });

  tearDownAll(() {
    try {
      final dir = Directory('test/temp_test_images');
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (e) {
      // Bỏ qua lỗi
    }
  });

  late MockClothingItemRepository mockClothingItemRepository;
  late ClothingItem initialItem;
  late File dummyImageFile;

  setUp(() async {
    mockClothingItemRepository = MockClothingItemRepository();
    dummyImageFile = await createDummyImage('test_image.png');
    initialItem = ClothingItem(
      id: 'item-123',
      name: 'Áo phông cũ',
      category: 'Áo > Áo thun',
      closetId: 'closet-1',
      imagePath: dummyImageFile.path,
      color: 'Trắng',
    );
    
    when(() => mockClothingItemRepository.getAllItems()).thenAnswer((_) async => [initialItem]);
    when(() => mockClothingItemRepository.updateItem(any())).thenAnswer((_) async {});
  });

  Future<void> pumpClosetsPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepository),
          closetsProvider.overrideWith((ref) => Future.value([
            Closet(id: 'closet-1', name: 'Tủ đồ của tôi')
          ])),
        ],
        child: const MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(body: ClosetsPage()),
          ),
        ),
      ),
    );
  }

  // --- KỊCH BẢN TEST HOÀN CHỈNH ---
  testWidgets('Luồng chỉnh sửa vật phẩm từ trang Tủ đồ', (WidgetTester tester) async {
    // ---- SẮP XẾP (ARRANGE) ----
    await pumpClosetsPage(tester);
    await tester.pump();

    // ---- HÀNH ĐỘNG (ACT) & KIỂM CHỨNG (ASSERT) ----

    final itemCardFinder = find.byKey(const ValueKey('item_card_item-123'));
    expect(itemCardFinder, findsOneWidget);

    await tester.tap(itemCardFinder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); 

    expect(find.text('Sửa món đồ'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Áo phông cũ'), findsOneWidget);

    const newItemName = 'Áo phông hàng hiệu mới';
    await tester.enterText(find.byType(TextFormField).first, newItemName);
    await tester.pump();

    // SỬA LỖI Ở ĐÂY: Tìm nút bấm bằng text "Cập nhật"
    await tester.tap(find.text('Cập nhật'));
    
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); 

    expect(find.text('Tất cả vật phẩm'), findsOneWidget);

    final captured = verify(() => mockClothingItemRepository.updateItem(captureAny())).captured;
    expect(captured.length, 1);
    final savedItem = captured.first as ClothingItem;
    
    expect(savedItem.name, newItemName);
    expect(savedItem.id, initialItem.id);
  });
}