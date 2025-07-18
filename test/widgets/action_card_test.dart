// test/widget_test/action_card_test.dart (hoặc test/action_card_test.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/widgets/action_card.dart';

void main() {
  testWidgets('ActionCard displays label and icon, and handles tap', (WidgetTester tester) async {
    bool tapped = false;

    // Bọc ActionCard trong một Row
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              ActionCard(
                label: 'Test Label',
                icon: Icons.add,
                onTap: () {
                  tapped = true;
                },
              ),
            ],
          ),
        ),
      ),
    );

    final labelFinder = find.text('Test Label');
    final iconFinder = find.byIcon(Icons.add);

    expect(labelFinder, findsOneWidget);
    expect(iconFinder, findsOneWidget);

    await tester.tap(find.byType(ActionCard));
    await tester.pump();

    expect(tapped, isTrue);
  });
}