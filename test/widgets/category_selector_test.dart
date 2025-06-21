// test/widgets/category_selector_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/theme/app_theme.dart'; // Import theme để có giao diện đầy đủ

void main() {
  // Hàm helper để bọc widget cần test trong một môi trường MaterialApp hoàn chỉnh
  // Điều này cần thiết để widget có thể truy cập Theme, Directionality, v.v.
  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      theme: appTheme, // Sử dụng theme thật của bạn
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('CategorySelector Widget Tests', () {
    testWidgets('Nên hiển thị đúng trạng thái ban đầu', (WidgetTester tester) async {
      // Sắp xếp (Arrange)
      // Bơm widget vào với giá trị ban đầu là null (chưa chọn)
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(onCategorySelected: (value) {}),
      ));

      // Kiểm chứng (Assert)
      // Tìm thấy nhãn "Danh mục *" và text "Chưa chọn"
      expect(find.text('Danh mục *'), findsOneWidget);
      expect(find.text('Chưa chọn'), findsOneWidget);
      // Ban đầu, danh sách các chip danh mục chính bị ẩn
      expect(find.text('Áo'), findsNothing);
    });

    testWidgets('Nên hiển thị danh mục chính khi nhấn vào', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(onCategorySelected: (value) {}),
      ));

      // Hành động (Act)
      // Nhấn vào widget để mở rộng danh sách
      await tester.tap(find.byType(InkWell));
      await tester.pump(); // Chờ UI cập nhật sau khi nhấn

      // Assert
      // Bây giờ các danh mục chính phải được hiển thị
      expect(find.text('Áo'), findsOneWidget);
      expect(find.text('Quần'), findsOneWidget);
      // Danh mục con vẫn bị ẩn
      expect(find.text('Áo thun (T-shirts)'), findsNothing);
    });

    testWidgets('Nên hiển thị danh mục con sau khi chọn danh mục chính', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(onCategorySelected: (value) {}),
      ));

      // Act
      // Mở rộng danh sách
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      
      // Chọn danh mục chính "Áo"
      await tester.tap(find.text('Áo'));
      await tester.pump();

      // Assert
      // Danh mục chính "Áo" không còn là chip để chọn nữa
      expect(find.widgetWithText(ActionChip, 'Áo'), findsNothing);
      // Thay vào đó, nó hiển thị như một chip đã chọn (Chip)
      expect(find.widgetWithText(Chip, 'Áo'), findsOneWidget);
      
      // Các danh mục con của "Áo" giờ phải được hiển thị
      expect(find.text('Áo thun (T-shirts)'), findsOneWidget);
      expect(find.text('Sơ mi (Shirts)'), findsOneWidget);
    });

    testWidgets('Nên gọi callback với giá trị đúng khi chọn danh mục con', (WidgetTester tester) async {
      // Arrange
      String? selectedValue; // Biến để lưu giá trị từ callback

      await tester.pumpWidget(createTestableWidget(
        CategorySelector(
          onCategorySelected: (value) {
            selectedValue = value; // Gán giá trị khi callback được gọi
          },
        ),
      ));

      // Act
      // 1. Mở rộng
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      // 2. Chọn danh mục chính "Quần"
      await tester.tap(find.text('Quần'));
      await tester.pump();
      // 3. Chọn danh mục con "Quần jeans"
      await tester.tap(find.text('Quần jeans'));
      await tester.pump();
      
      // Assert
      // Kiểm tra xem callback đã được gọi và lưu đúng giá trị chưa
      expect(selectedValue, 'Quần > Quần jeans');
    });

    testWidgets('Nên reset về trạng thái ban đầu khi nhấn nút xóa', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(
          initialCategory: 'Áo > Áo thun (T-shirts)',
          onCategorySelected: (value) {},
        ),
      ));
      // Mở rộng danh sách để có thể thấy các nút
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Kiểm tra trạng thái ban đầu sau khi pump
      expect(find.widgetWithText(Chip, 'Áo'), findsOneWidget);

      // Act
      // Tìm nút xóa (Icon.close) bên trong Chip và nhấn vào nó
      await tester.tap(find.descendant(of: find.widgetWithText(Chip, 'Áo'), matching: find.byIcon(Icons.close)));
      await tester.pump();

      // Assert
      // Widget phải quay về trạng thái hiển thị danh sách các danh mục chính
      expect(find.text('Áo'), findsOneWidget);
      expect(find.text('Quần'), findsOneWidget);
      // Không còn chip nào đang được chọn
      expect(find.widgetWithText(Chip, 'Áo'), findsNothing);
    });
  });
}