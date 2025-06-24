// test/widgets/recent_item_card_test.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/widgets/recent_item_card.dart';

void main() {
  // Tạo file ảnh giả để test
  setUpAll(() async {
    final d = Directory('test/temp_test_images');
    if (!d.existsSync()) d.createSync(recursive: true);
    await File('test/temp_test_images/image.png').writeAsBytes([1,2,3]);
    await File('test/temp_test_images/thumb.png').writeAsBytes([1,2,3,4]);
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 120, height: 160, child: child))));
  }

  testWidgets('Nên hiển thị thumbnailPath khi nó tồn tại', (tester) async {
    // Arrange
    final itemWithThumb = ClothingItem(
      id: '1', name: 'Test', category: 'Cat', color: 'Color', closetId: 'c1',
      imagePath: 'test/temp_test_images/image.png',
      thumbnailPath: 'test/temp_test_images/thumb.png',
    );

    // Act
    await tester.pumpWidget(createTestableWidget(RecentItemCard(item: itemWithThumb)));

    // Assert
    final imageWidget = tester.widget<Image>(find.byType(Image));
    final fileImage = imageWidget.image as FileImage;

    // Kiểm tra xem nó có đang dùng đúng đường dẫn của thumbnail không
    expect(fileImage.file.path, endsWith('thumb.png'));
  });

  testWidgets('Nên hiển thị imagePath khi thumbnailPath là null', (tester) async {
    // Arrange
    final itemWithoutThumb = ClothingItem(
      id: '1', name: 'Test', category: 'Cat', color: 'Color', closetId: 'c1',
      imagePath: 'test/temp_test_images/image.png',
      thumbnailPath: null, // Không có thumbnail
    );

    // Act
    await tester.pumpWidget(createTestableWidget(RecentItemCard(item: itemWithoutThumb)));

    // Assert
    final imageWidget = tester.widget<Image>(find.byType(Image));
    final fileImage = imageWidget.image as FileImage;

    // Kiểm tra xem nó có quay về dùng đường dẫn của ảnh gốc không
    expect(fileImage.file.path, endsWith('image.png'));
  });
}