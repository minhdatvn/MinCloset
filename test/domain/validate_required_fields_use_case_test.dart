// test/domain/validate_required_fields_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/states/add_item_state.dart';

void main() {
  final useCase = ValidateRequiredFieldsUseCase();

  group('ValidateRequiredFieldsUseCase - forSingleItem', () {
    test('Nên trả về thành công khi tất cả các trường đều hợp lệ', () {
      const validState = AddItemState(
        name: 'Áo thun',
        selectedClosetId: 'closet1',
        selectedCategoryValue: 'Áo > Áo thun',
      );
      final result = useCase.executeForSingle(validState);
      expect(result.success, isTrue);
    });

    test('Nên trả về thất bại khi tên bị thiếu', () {
      const invalidState = AddItemState(
        name: ' ', // Tên trống
        selectedClosetId: 'closet1',
        selectedCategoryValue: 'Áo > Áo thun',
      );
      final result = useCase.executeForSingle(invalidState);
      expect(result.success, isFalse);
      // <<< Sửa chuỗi Tiếng Việt thành Tiếng Anh >>>
      expect(result.errorMessage, 'Please enter item name');
    });

    test('Nên trả về thất bại khi tủ đồ bị thiếu', () {
      const invalidState = AddItemState(
        name: 'Áo thun',
        selectedClosetId: null, // Thiếu tủ đồ
        selectedCategoryValue: 'Áo > Áo thun',
      );
      final result = useCase.executeForSingle(invalidState);
      expect(result.success, isFalse);
      // <<< Sửa chuỗi Tiếng Việt thành Tiếng Anh >>>
      expect(result.errorMessage, 'Please select a closet');
    });

    test('Nên trả về thất bại khi danh mục bị thiếu', () {
      const invalidState = AddItemState(
        name: 'Áo thun',
        selectedClosetId: 'closet1',
        selectedCategoryValue: '', // Thiếu danh mục
      );
      final result = useCase.executeForSingle(invalidState);
      expect(result.success, isFalse);
      // <<< Sửa chuỗi Tiếng Việt thành Tiếng Anh >>>
      expect(result.errorMessage, 'Please select a category');
    });
  });

  group('ValidateRequiredFieldsUseCase - forBatch', () {
    test('Nên trả về thành công khi tất cả các món đồ trong lô đều hợp lệ', () {
      const validBatch = [
        AddItemState(name: 'Áo 1', selectedClosetId: 'c1', selectedCategoryValue: 'cat1'),
        AddItemState(name: 'Áo 2', selectedClosetId: 'c1', selectedCategoryValue: 'cat2'),
      ];
      final result = useCase.executeForBatch(validBatch);
      expect(result.success, isTrue);
    });

    test('Nên trả về thất bại và đúng errorIndex khi một món đồ trong lô không hợp lệ', () {
      const invalidBatch = [
        AddItemState(name: 'Áo 1', selectedClosetId: 'c1', selectedCategoryValue: 'cat1'),
        AddItemState(name: 'Áo 2', selectedClosetId: null, selectedCategoryValue: 'cat2'), // Món đồ này thiếu closetId
        AddItemState(name: 'Áo 3', selectedClosetId: 'c1', selectedCategoryValue: 'cat3'),
      ];
      final result = useCase.executeForBatch(invalidBatch);
      expect(result.success, isFalse);
      // <<< Sửa chuỗi Tiếng Việt thành Tiếng Anh >>>
      expect(result.errorMessage, 'Please select a closet for Item 2');
      expect(result.errorIndex, 1);
    });
  });
}