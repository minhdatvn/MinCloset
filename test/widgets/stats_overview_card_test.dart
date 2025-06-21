// test/widgets/stats_overview_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/widgets/stats_overview_card.dart';

void main() {
  // `testWidgets` là hàm đặc biệt dùng để test các widget.
  // Nó cung cấp một đối tượng `WidgetTester` để tương tác với widget.
  testWidgets('StatsOverviewCard nên hiển thị đúng các số liệu thống kê', (WidgetTester tester) async {
    // SẮP XẾP (Arrange)
    // 1. Các số liệu thống kê mẫu mà chúng ta muốn test
    const totalItems = 123;
    const totalClosets = 4;
    const totalOutfits = 15;

    // 2. "Bơm" (pump) widget vào màn hình ảo.
    // Chúng ta cần bọc nó trong MaterialApp và Scaffold để cung cấp
    // các theme và context cần thiết cho widget hoạt động đúng.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsOverviewCard(
            totalItems: totalItems,
            totalClosets: totalClosets,
            totalOutfits: totalOutfits,
          ),
        ),
      ),
    );

    // HÀNH ĐỘNG & KIỂM CHỨNG (Act & Assert)
    // 3. Sử dụng `find.text()` để tìm kiếm các đoạn text trên màn hình ảo.
    // 4. Sử dụng `expect(..., findsOneWidget)` để xác minh rằng mỗi đoạn text
    //    chỉ xuất hiện đúng một lần.

    // Kiểm tra các con số
    expect(find.text(totalItems.toString()), findsOneWidget);
    expect(find.text(totalClosets.toString()), findsOneWidget);
    expect(find.text(totalOutfits.toString()), findsOneWidget);

    // Kiểm tra các nhãn
    expect(find.text('Vật phẩm'), findsOneWidget);
    expect(find.text('Tủ đồ'), findsOneWidget);
    expect(find.text('Bộ đồ'), findsOneWidget);
  });
}