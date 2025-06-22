// test/repositories/closet_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mocktail/mocktail.dart';

// 1. Mock DatabaseHelper, là phụ thuộc duy nhất của ClosetRepository
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  late ClosetRepository repository;
  late MockDatabaseHelper mockDbHelper;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    repository = ClosetRepository(mockDbHelper);
  });

  group('ClosetRepository', () {
    // Dữ liệu mẫu
    final tCloset = Closet(id: 'c1', name: 'Tủ đồ Mùa đông');

    test('getClosets - nên trả về một List<Closet> khi dbHelper trả về dữ liệu', () async {
      // Sắp xếp (Arrange)
      // Dữ liệu thô mà dbHelper sẽ trả về (dạng List<Map>)
      final tClosetMapList = [
        {'id': 'c1', 'name': 'Tủ đồ Mùa đông'},
        {'id': 'c2', 'name': 'Tủ đồ Mùa hè'},
      ];
      // Giả lập rằng khi gọi getClosets, dbHelper sẽ trả về dữ liệu trên
      when(() => mockDbHelper.getClosets()).thenAnswer((_) async => tClosetMapList);

      // Hành động (Act)
      final result = await repository.getClosets();

      // Kiểm chứng (Assert)
      // 1. Kiểm tra kiểu dữ liệu trả về là đúng
      expect(result, isA<List<Closet>>());
      // 2. Kiểm tra số lượng phần tử
      expect(result.length, 2);
      // 3. Kiểm tra xem phần tử đầu tiên có được chuyển đổi đúng không
      expect(result.first.name, 'Tủ đồ Mùa đông');
      // 4. Xác minh rằng phương thức của dbHelper đã được gọi
      verify(() => mockDbHelper.getClosets()).called(1);
    });

    test('insertCloset - nên gọi insertCloset trên dbHelper với dữ liệu đã toMap()', () async {
      // Sắp xếp
      // Giả lập hàm insertCloset của dbHelper không làm gì cả
      when(() => mockDbHelper.insertCloset(any())).thenAnswer((_) async {});

      // Hành động
      await repository.insertCloset(tCloset);

      // Kiểm chứng
      // Xác minh rằng dbHelper.insertCloset đã được gọi với đúng đối số.
      // Đối số mong đợi là kết quả của `tCloset.toMap()`.
      verify(() => mockDbHelper.insertCloset(tCloset.toMap())).called(1);
    });

    test('deleteCloset - nên gọi deleteCloset trên dbHelper với id chính xác', () async {
      // Sắp xếp
      const tClosetId = 'c1';
      when(() => mockDbHelper.deleteCloset(any())).thenAnswer((_) async {});
      
      // Hành động
      await repository.deleteCloset(tClosetId);

      // Kiểm chứng
      verify(() => mockDbHelper.deleteCloset(tClosetId)).called(1);
    });

    // Bạn có thể viết thêm bài test cho `updateCloset` theo logic tương tự.
  });
}