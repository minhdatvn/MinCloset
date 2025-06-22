// test/domain/validate_required_fields_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/states/add_item_state.dart';

void main() {
  // Vì use case này không có phụ thuộc, chúng ta có thể khởi tạo nó trực tiếp.
  final useCase = ValidateRequiredFieldsUseCase();

  group('ValidateRequiredFieldsUseCase - forSingleItem', () {
    test('Nên trả về thành công khi tất cả các trường đều hợp lệ', () {
      // Sắp xếp (Arrange)
      const validState = AddItemState(
        name: 'Áo thun',
        selectedClosetId: 'closet1',
        selectedCategoryValue: 'Áo > Áo thun',
      );

      // Hành động (Act)
      final result = useCase.executeForSingle(validState);

      // Kiểm chứng (Assert)
      expect(result.success, isTrue);
    });

    test('Nên trả về thất bại khi tên bị thiếu', () {
      // Sắp xếp (Arrange)
      const invalidState = AddItemState(
        name: ' ', // Tên trống
        selectedClosetId: 'closet1',
        selectedCategoryValue: 'Áo > Áo thun',
      );

      // Hành động (Act)
      final result = useCase.executeForSingle(invalidState);

      // Kiểm chứng (Assert)
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Vui lòng nhập tên');
    });

    test('Nên trả về thất bại khi tủ đồ bị thiếu', () {
      // Sắp xếp (Arrange)
      const invalidState = AddItemState(
        name: 'Áo thun',
        selectedClosetId: null, // Thiếu tủ đồ
        selectedCategoryValue: 'Áo > Áo thun',
      );

      // Hành động (Act)
      final result = useCase.executeForSingle(invalidState);

      // Kiểm chứng (Assert)
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Vui lòng chọn tủ quần áo');
    });

    test('Nên trả về thất bại khi danh mục bị thiếu', () {
      // Sắp xếp (Arrange)
      const invalidState = AddItemState(
        name: 'Áo thun',
        selectedClosetId: 'closet1',
        selectedCategoryValue: '', // Thiếu danh mục
      );

      // Hành động (Act)
      final result = useCase.executeForSingle(invalidState);

      // Kiểm chứng (Assert)
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Vui lòng chọn danh mục');
    });
  });

  group('ValidateRequiredFieldsUseCase - forBatch', () {
    test('Nên trả về thành công khi tất cả các món đồ trong lô đều hợp lệ', () {
      // Sắp xếp (Arrange)
      const validBatch = [
        AddItemState(name: 'Áo 1', selectedClosetId: 'c1', selectedCategoryValue: 'cat1'),
        AddItemState(name: 'Áo 2', selectedClosetId: 'c1', selectedCategoryValue: 'cat2'),
      ];

      // Hành động (Act)
      final result = useCase.executeForBatch(validBatch);

      // Kiểm chứng (Assert)
      expect(result.success, isTrue);
    });

    test('Nên trả về thất bại và đúng errorIndex khi một món đồ trong lô không hợp lệ', () {
      // Sắp xếp (Arrange)
      const invalidBatch = [
        AddItemState(name: 'Áo 1', selectedClosetId: 'c1', selectedCategoryValue: 'cat1'),
        AddItemState(name: 'Áo 2', selectedClosetId: null, selectedCategoryValue: 'cat2'), // Món đồ này thiếu closetId
        AddItemState(name: 'Áo 3', selectedClosetId: 'c1', selectedCategoryValue: 'cat3'),
      ];

      // Hành động (Act)
      final result = useCase.executeForBatch(invalidBatch);

      // Kiểm chứng (Assert)
      expect(result.success, isFalse);
      // Kiểm tra thông báo lỗi có chứa chỉ số của món đồ bị lỗi
      expect(result.errorMessage, contains('Món đồ số 2'));
      // Kiểm tra chỉ số lỗi trả về là 1 (món đồ thứ 2 trong danh sách)
      expect(result.errorIndex, 1);
    });
  });
}