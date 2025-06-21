// test/repositories/clothing_item_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

// 1. Tạo lớp Mock cho DatabaseHelper
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

// 2. Tạo lớp Fake cho ClothingItem để sử dụng trong `registerFallbackValue`
class FakeClothingItem extends Fake implements ClothingItem {}

void main() {
  late ClothingItemRepository repository;
  late MockDatabaseHelper mockDbHelper;

  // 3. Đăng ký FallbackValue cho lớp Fake
  // Điều này cần thiết để mocktail có thể khớp với các đối số là đối tượng tùy chỉnh
  setUpAll(() {
    registerFallbackValue(FakeClothingItem());
  });

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    repository = ClothingItemRepository(mockDbHelper);
  });

  // Dữ liệu mẫu trả về từ CSDL (dạng Map)
  final tItemId = const Uuid().v4();
  final tClothingItemMap = {
    'id': tItemId,
    'name': 'Test Item',
    'category': 'Áo > Áo thun',
    'color': 'Trắng',
    'imagePath': 'path/to/image.jpg',
    'closetId': 'closet1',
    'season': 'Hạ',
    'occasion': 'Hằng ngày',
    'material': 'Cotton',
    'pattern': 'Trơn',
  };

  // Đối tượng ClothingItem tương ứng
  final tClothingItemModel = ClothingItem.fromMap(tClothingItemMap);

  group('getItemById', () {
    test('Nên trả về ClothingItem khi CSDL tìm thấy một item', () async {
      // Sắp xếp (Arrange)
      when(() => mockDbHelper.getItemById(any())).thenAnswer((_) async => tClothingItemMap);

      // Hành động (Act)
      final result = await repository.getItemById(tItemId);

      // Kiểm chứng (Assert)
      expect(result, equals(tClothingItemModel));
      // Xác minh rằng phương thức của dbHelper được gọi đúng 1 lần với id chính xác
      verify(() => mockDbHelper.getItemById(tItemId)).called(1);
    });

    test('Nên trả về null khi CSDL không tìm thấy item', () async {
      // Arrange
      when(() => mockDbHelper.getItemById(any())).thenAnswer((_) async => null);

      // Act
      final result = await repository.getItemById(tItemId);

      // Assert
      expect(result, isNull);
      verify(() => mockDbHelper.getItemById(tItemId)).called(1);
    });
  });

  group('getAllItems', () {
    test('Nên trả về một danh sách ClothingItem', () async {
      // Arrange
      final itemListMap = [tClothingItemMap];
      when(() => mockDbHelper.getAllItems()).thenAnswer((_) async => itemListMap);

      // Act
      final result = await repository.getAllItems();

      // Assert
      expect(result, isA<List<ClothingItem>>());
      expect(result.length, 1);
      expect(result.first.name, 'Test Item');
      verify(() => mockDbHelper.getAllItems()).called(1);
    });
  });

  group('insertItem', () {
    test('Nên gọi insertItem trên dbHelper với dữ liệu chính xác', () async {
      // Arrange
      // Giả lập cho hàm insert không làm gì cả
      when(() => mockDbHelper.insertItem(any())).thenAnswer((_) async {});

      // Act
      await repository.insertItem(tClothingItemModel);

      // Assert
      // Xác minh rằng dbHelper.insertItem được gọi với một Map khớp với toMap() của model
      verify(() => mockDbHelper.insertItem(tClothingItemModel.toMap())).called(1);
    });
  });

  group('deleteItem', () {
    test('Nên gọi deleteItem trên dbHelper với id chính xác', () async {
      // Arrange
      when(() => mockDbHelper.deleteItem(any())).thenAnswer((_) async {});

      // Act
      await repository.deleteItem(tItemId);

      // Assert
      verify(() => mockDbHelper.deleteItem(tItemId)).called(1);
    });
  });

  // Bạn có thể thêm các bài test tương tự cho các phương thức khác như
  // updateItem, getItemsInCloset, v.v.
}