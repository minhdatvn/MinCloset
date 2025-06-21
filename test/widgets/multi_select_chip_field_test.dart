// test/widgets/multi_select_chip_field_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/widgets/multi_select_chip_field.dart';

void main() {
  // A helper function to wrap the widget in a testable environment
  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        // Provide a basic theme to avoid potential rendering errors
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(body: child),
    );
  }

  group('MultiSelectChipField Tests', () {
    testWidgets('Should display initial selections correctly', (WidgetTester tester) async {
      // Arrange
      // Using English for test data as requested
      final initialSelections = {'Spring', 'Summer'};
      final allSeasons = ['Spring', 'Summer', 'Fall', 'Winter']; // Using a local list to match AppOptions

      await tester.pumpWidget(createTestableWidget(
        MultiSelectChipField(
          label: 'Season',
          allOptions: allSeasons,
          initialSelections: initialSelections,
          onSelectionChanged: (newSelections) {},
        ),
      ));

      // Act: Expand the selection area
      await tester.tap(find.byType(InkWell));
      await tester.pump(); // Wait for the UI to update

      // Assert
      // Find the specific FilterChip widget and check its 'selected' property
      final springChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Spring'));
      expect(springChip.selected, isTrue);

      final summerChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Summer'));
      expect(summerChip.selected, isTrue);

      final fallChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Fall'));
      expect(fallChip.selected, isFalse);
    });

    testWidgets('Should select and deselect items on tap', (WidgetTester tester) async {
      // Arrange
      Set<String> currentSelections = {}; // Start with an empty set
      final allSeasons = ['Spring', 'Summer', 'Fall', 'Winter'];

      // To test the callback, we need a stateful parent to hold the state
      await tester.pumpWidget(createTestableWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MultiSelectChipField(
              label: 'Season',
              allOptions: allSeasons,
              initialSelections: currentSelections,
              onSelectionChanged: (newSelections) {
                // When the callback is invoked, update the external state
                setState(() {
                  currentSelections = newSelections;
                });
              },
            );
          },
        ),
      ));

      // Expand the selection area
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // --- SCENARIO 1: SELECT AN ITEM ---
      // Act: Simulate a tap on the 'Summer' chip
      // <<< FIX: Use a more specific finder to avoid ambiguity >>>
      await tester.tap(find.widgetWithText(FilterChip, 'Summer'));
      await tester.pump(); // Rebuild the widget with the new state

      // Assert: Check if the callback updated the state correctly
      expect(currentSelections, equals({'Summer'}));
      // Also check the UI to ensure the 'Summer' chip is visually selected
      final summerChipSelected = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Summer'));
      expect(summerChipSelected.selected, isTrue);


      // --- SCENARIO 2: DESELECT THAT ITEM ---
      // Act: Tap the 'Summer' chip again
      // <<< FIX: Use the specific finder here as well >>>
      await tester.tap(find.widgetWithText(FilterChip, 'Summer'));
      await tester.pump();

      // Assert: The state should now be empty
      expect(currentSelections, isEmpty);
      // The 'Summer' chip UI should be unselected
      final summerChipUnselected = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Summer'));
      expect(summerChipUnselected.selected, isFalse);
    });
  });
}