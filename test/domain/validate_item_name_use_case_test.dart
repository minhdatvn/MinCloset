// test/domain/validate_item_name_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mocktail/mocktail.dart';

class MockClothingItemRepository extends Mock implements ClothingItemRepository {}

void main() {
  late ValidateItemNameUseCase useCase;
  late MockClothingItemRepository mockRepository;

  setUp(() {
    mockRepository = MockClothingItemRepository();
    useCase = ValidateItemNameUseCase(mockRepository);
  });

  final existingItems = [
    const ClothingItem(id: '1', name: 'Áo thun trắng', category: 'Áo', color: 'Trắng', imagePath: 'path1', closetId: 'c1'),
    const ClothingItem(id: '2', name: 'Quần Jeans Xanh', category: 'Quần', color: 'Xanh', imagePath: 'path2', closetId: 'c1'),
  ];

  group('ValidateItemNameUseCase - forSingleItem', () {
    test('Nên trả về thành công khi tên là duy nhất', () async {
      // ARRANGE
      // Sửa mock để linh hoạt hơn
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => existingItems);

      // ACT
      final result = await useCase.forSingleItem(name: 'Sơ mi caro');

      // ASSERT
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('Nên trả về thất bại khi tên đã tồn tại (phân biệt chữ hoa/thường)', () async {
      // Arrange
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => existingItems);

      // Act
      final result = await useCase.forSingleItem(name: 'áo thun trắng '); // Có khoảng trắng thừa

      // Assert
      expect(result.success, isFalse);
      // Sửa lại chuỗi mong đợi thành tiếng Anh
      expect(result.errorMessage, contains('is already taken'));
    });

    test('Nên trả về thành công khi chỉnh sửa và giữ nguyên tên', () async {
      // Arrange
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => existingItems);

      // Act
      final result = await useCase.forSingleItem(name: 'Áo thun trắng', existingId: '1');

      // Assert
      expect(result.success, isTrue);
    });

    test('Nên trả về thất bại khi sửa tên thành một tên đã tồn tại khác', () async {
      // Arrange
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => existingItems);

      // Act
      final result = await useCase.forSingleItem(name: 'Quần Jeans Xanh', existingId: '1');

      // Assert
      expect(result.success, isFalse);
      // Sửa lại chuỗi mong đợi thành tiếng Anh
      expect(result.errorMessage, contains('is already taken'));
    });
  });

  group('ValidateItemNameUseCase - forBatch', () {
    test('Nên trả về thất bại nếu có tên trùng lặp trong cùng một lô', () async {
      // Arrange
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => []);
      
      final batchWithDuplicates = [
        const AddItemState(name: 'Áo khoác da'),
        const AddItemState(name: 'Giày sneaker'),
        const AddItemState(name: 'Áo khoác da'), // Tên trùng lặp
      ];

      // Act
      final ValidationResult result = await useCase.forBatch(batchWithDuplicates);

      // Assert
      expect(result.success, isFalse);
      expect(result.errorIndex, 2, reason: 'Lỗi phải được báo cáo ở món đồ thứ 3');
      // Sửa lại chuỗi mong đợi thành tiếng Anh
      expect(result.errorMessage, contains('is already used by item 1'));
    });

    test('Nên trả về thất bại nếu có tên trong lô trùng với CSDL', () async {
      // Arrange
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => existingItems);
      
      final batchWithDbDuplicate = [
        const AddItemState(name: 'Áo khoác da'),
        const AddItemState(name: 'Quần Jeans Xanh'), // Trùng với CSDL
      ];

      // Act
      final ValidationResult result = await useCase.forBatch(batchWithDbDuplicate);

      // Assert
      expect(result.success, isFalse);
      expect(result.errorIndex, 1, reason: 'Lỗi phải được báo cáo ở món đồ thứ 2');
      // Sửa lại chuỗi mong đợi thành tiếng Anh
      expect(result.errorMessage, contains('is already taken'));
    });

    test('Nên trả về thành công nếu tất cả tên trong lô đều hợp lệ', () async {
      // Arrange
      when(() => mockRepository.getAllItems(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => existingItems);
      
      final validBatch = [
        const AddItemState(name: 'Áo khoác da'),
        const AddItemState(name: 'Giày sneaker'),
      ];

      // Act
      final ValidationResult result = await useCase.forBatch(validBatch);

      // Assert
      expect(result.success, isTrue);
    });
  });
}