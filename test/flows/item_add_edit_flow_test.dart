// test/flows/item_add_edit_flow_test.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/screens/pages/closets_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';

// Helper classes
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}
class FakeClothingItem extends Fake implements ClothingItem {}

// Helper function to create a dummy image file for testing
Future<File> createDummyImage(String name) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$name');
  await file.writeAsBytes(Uint8List(0));
  return file;
}

void main() {
  late MockClothingItemRepository mockClothingItemRepository;

  setUpAll(() {
    registerFallbackValue(FakeClothingItem());
  });

  setUp(() {
    mockClothingItemRepository = MockClothingItemRepository();
  });

  // This helper now pumps ONLY the ClosetsPage
  Future<void> pumpClosetsPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clothingItemRepositoryProvider.overrideWithValue(mockClothingItemRepository),
          // We also need to mock closetsProvider as ClosetsPage depends on it
          closetsProvider.overrideWith((ref) => []),
        ],
        child: const MaterialApp(
          // We need a TabController for the ClosetsPage
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: ClosetsPage(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Full item edit flow starting from ClosetsPage', (WidgetTester tester) async {
    // ARRANGE
    final dummyImageFile = await createDummyImage('test_image.png');
    addTearDown(() async {
      if (await dummyImageFile.exists()) await dummyImageFile.delete();
    });

    final initialItem = ClothingItem(
      id: 'item-123',
      name: 'Old T-Shirt',
      category: 'Top',
      closetId: 'closet-1',
      imagePath: dummyImageFile.path,
      color: 'White',
    );

    // Mock the necessary repository calls for this specific flow
    when(() => mockClothingItemRepository.getAllItems()).thenAnswer((_) async => [initialItem]);
    when(() => mockClothingItemRepository.updateItem(any())).thenAnswer((_) async {});
    when(() => mockClothingItemRepository.searchItemsInCloset(any(), any())).thenAnswer((_) async => []);

    // PUMP THE WIDGET
    await pumpClosetsPage(tester);
    // This pumpAndSettle will now be very fast as it doesn't load HomePage
    await tester.pumpAndSettle();

    // ACTION & ASSERT
    // 1. Verify the item is visible on the 'All Items' tab
    expect(find.text('Old T-Shirt'), findsOneWidget);

    // 2. Tap on the item to edit it
    await tester.tap(find.text('Old T-Shirt'));
    await tester.pumpAndSettle();

    // 3. Verify we are on the edit screen
    expect(find.text('Edit Item'), findsOneWidget);

    // 4. Edit the name field
    const newItemName = 'New Branded T-Shirt';
    await tester.enterText(find.byType(TextFormField).first, newItemName);
    await tester.pump();

    // 5. Tap the save button
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // 6. Verify we are back on the ClosetsPage
    expect(find.text('All Items'), findsOneWidget);

    // 7. Verify that `updateItem` was called with the correct data
    final captured = verify(() => mockClothingItemRepository.updateItem(captureAny())).captured;
    expect(captured.length, 1);
    final savedItem = captured.first as ClothingItem;
    expect(savedItem.name, newItemName);
    expect(savedItem.id, initialItem.id);
  });
}