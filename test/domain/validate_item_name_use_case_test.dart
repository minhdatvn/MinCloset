// test/domain/validate_item_name_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/domain/use_cases/validate_item_name_use_case.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mocktail/mocktail.dart';

// 1. Tạo một lớp Mock cho Repository mà UseCase phụ thuộc vào
class MockClothingItemRepository extends Mock implements ClothingItemRepository {}

void main() {
  // 2. Khai báo các biến cần thiết
  late ValidateItemNameUseCase useCase;
  late MockClothingItemRepository mockRepository;

  // 3. Dùng `setUp` để khởi tạo các đối tượng trước mỗi bài test
  setUp(() {
    mockRepository = MockClothingItemRepository();
    useCase = ValidateItemNameUseCase(mockRepository);
  });

  // Dữ liệu giả để dùng trong các bài test
  final existingItems = [
    const ClothingItem(id: '1', name: 'Áo thun trắng', category: 'Áo', color: 'Trắng', imagePath: 'path1', closetId: 'c1'),
    const ClothingItem(id: '2', name: 'Quần Jeans Xanh', category: 'Quần', color: 'Xanh', imagePath: 'path2', closetId: 'c1'),
  ];

  group('ValidateItemNameUseCase - forSingleItem', () {
    test('Nên trả về thành công khi tên là duy nhất', () async {
      // SẮP XẾP (Arrange)
      // Giả lập rằng khi repo được gọi, nó sẽ trả về danh sách item đã có
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => existingItems);

      // HÀNH ĐỘNG (Act)
      final result = await useCase.forSingleItem(name: 'Sơ mi caro');

      // KIỂM CHỨNG (Assert)
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('Nên trả về thất bại khi tên đã tồn tại (phân biệt chữ hoa/thường)', () async {
      // Arrange
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => existingItems);

      // Act
      // Tên 'áo thun trắng' gần giống 'Áo thun trắng'
      final result = await useCase.forSingleItem(name: 'áo thun trắng '); // Có khoảng trắng thừa

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('đã được dùng'));
    });

    test('Nên trả về thành công khi chỉnh sửa và giữ nguyên tên', () async {
      // Arrange
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => existingItems);

      // Act
      // Sửa item có id='1' và giữ nguyên tên là 'Áo thun trắng'
      final result = await useCase.forSingleItem(name: 'Áo thun trắng', existingId: '1');

      // Assert
      expect(result.success, isTrue);
    });

    test('Nên trả về thất bại khi sửa tên thành một tên đã tồn tại khác', () async {
      // Arrange
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => existingItems);

      // Act
      // Cố gắng sửa item có id='1' thành tên 'Quần Jeans Xanh' (của item id='2')
      final result = await useCase.forSingleItem(name: 'Quần Jeans Xanh', existingId: '1');

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('đã được dùng'));
    });
  });

  group('ValidateItemNameUseCase - forBatch', () {
    test('Nên trả về thất bại nếu có tên trùng lặp trong cùng một lô', () async {
      // Arrange
      // Giả sử CSDL rỗng
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => []);
      
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
      expect(result.errorMessage, contains('đã trùng với món đồ 1'));
    });

    test('Nên trả về thất bại nếu có tên trong lô trùng với CSDL', () async {
      // Arrange
      // Giả sử CSDL đã có 'Quần Jeans Xanh'
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => existingItems);
      
      final batchWithDbDuplicate = [
        const AddItemState(name: 'Áo khoác da'),
        const AddItemState(name: 'Quần Jeans Xanh'), // Trùng với CSDL
      ];

      // Act
      final ValidationResult result = await useCase.forBatch(batchWithDbDuplicate);

      // Assert
      expect(result.success, isFalse);
      expect(result.errorIndex, 1, reason: 'Lỗi phải được báo cáo ở món đồ thứ 2');
      expect(result.errorMessage, contains('đã được dùng'));
    });

    test('Nên trả về thành công nếu tất cả tên trong lô đều hợp lệ', () async {
      // Arrange
      when(() => mockRepository.getAllItems()).thenAnswer((_) async => existingItems);
      
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