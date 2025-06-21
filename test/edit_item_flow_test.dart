// test/edit_item_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/screens/add_item_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

// <<< THAY ĐỔI 1: TẠO LỚP FAKE CHO ClothingItem >>>
class FakeClothingItem extends Fake implements ClothingItem {}

class MockClothingItemRepository extends Mock implements ClothingItemRepository {}

void main() {
  // <<< THAY ĐỔI 2: THÊM setUpAll ĐỂ ĐĂNG KÝ FALLBACK VALUE >>>
  setUpAll(() {
    registerFallbackValue(FakeClothingItem());
  });

  late MockClothingItemRepository mockClothingItemRepository;
  late ClothingItem testItem;

  setUp(() {
    mockClothingItemRepository = MockClothingItemRepository();
    testItem = ClothingItem(
      id: const Uuid().v4(),
      name: 'Áo thun cũ',
      category: 'Áo',
      closetId: 'closet1',
      imagePath: 'path/to/image',
      color: 'Trắng',
    );
    
    // Giờ đây `any()` sẽ hoạt động vì đã có fallback value
    when(() => mockClothingItemRepository.updateItem(any()))
        .thenAnswer((_) async {});
    when(() => mockClothingItemRepository.getAllItems())
        .thenAnswer((_) async => []);
  });

  testWidgets(
      'AddItemScreen should not auto-close on second consecutive edit',
      (WidgetTester tester) async {
    
    Future<void> performEditCycle(String newName) async {
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Sửa món đồ'), findsOneWidget,
          reason: 'AddItemScreen should be open for editing');

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, newName);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(find.text('Test Launcher'), findsOneWidget,
          reason: 'Should return to launcher screen after saving');
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clothingItemRepositoryProvider
              .overrideWithValue(mockClothingItemRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test Launcher')),
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddItemScreen(itemToEdit: testItem),
                      ),
                    );
                  },
                  child: const Text('Edit Item'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await performEditCycle('Tên mới lần 1');
    await performEditCycle('Tên mới lần 2');
    await performEditCycle('Tên mới lần 3');
  });
}