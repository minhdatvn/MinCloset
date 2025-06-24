// test/widgets/category_selector_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/widgets/category_selector.dart';
import 'package:mincloset/theme/app_theme.dart';

void main() {
  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('CategorySelector Widget Tests', () {
    testWidgets('Should display initial state correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(onCategorySelected: (value) {}),
      ));

      // Assert
      // <<< Sửa chuỗi tìm kiếm sang tiếng Anh >>>
      expect(find.text('Category *'), findsOneWidget);
      expect(find.text('None selected'), findsOneWidget);
      expect(find.text('Áo'), findsNothing);
    });

    testWidgets('Should display main categories on tap', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(onCategorySelected: (value) {}),
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(find.text('Áo'), findsOneWidget);
      expect(find.text('Quần'), findsOneWidget);
      expect(find.text('Áo thun (T-shirts)'), findsNothing);
    });

    testWidgets('Should display sub-categories after selecting a main category', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(onCategorySelected: (value) {}),
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      
      await tester.tap(find.text('Áo'));
      await tester.pump();

      // Assert
      expect(find.widgetWithText(ActionChip, 'Áo'), findsNothing);
      expect(find.widgetWithText(Chip, 'Áo'), findsOneWidget);
      expect(find.text('Áo thun (T-shirts)'), findsOneWidget);
      expect(find.text('Sơ mi (Shirts)'), findsOneWidget);
    });

    testWidgets('Should call callback with correct value when selecting a sub-category', (WidgetTester tester) async {
      // Arrange
      String? selectedValue;
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(
          onCategorySelected: (value) {
            selectedValue = value;
          },
        ),
      ));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      await tester.tap(find.text('Quần'));
      await tester.pump();
      await tester.tap(find.text('Quần jeans'));
      await tester.pump();
      
      // Assert
      expect(selectedValue, 'Quần > Quần jeans');
    });

    testWidgets('Should reset to initial state when clear button is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        CategorySelector(
          initialCategory: 'Áo > Áo thun (T-shirts)',
          onCategorySelected: (value) {},
        ),
      ));
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert initial state
      expect(find.widgetWithText(Chip, 'Áo'), findsOneWidget);

      // Act
      await tester.tap(find.descendant(of: find.widgetWithText(Chip, 'Áo'), matching: find.byIcon(Icons.close)));
      await tester.pump();

      // Assert final state
      expect(find.text('Áo'), findsOneWidget);
      expect(find.text('Quần'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Áo'), findsNothing);
    });
  });
}