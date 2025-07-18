// test/domain/use_cases/validate_required_fields_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/domain/use_cases/validate_required_fields_use_case.dart';
import 'package:mincloset/states/item_detail_state.dart';

void main() {
  // Khởi tạo UseCase cần test
  late ValidateRequiredFieldsUseCase useCase;

  setUp(() {
    useCase = ValidateRequiredFieldsUseCase();
  });

  group('ValidateRequiredFieldsUseCase - executeForSingle', () {
    test('Nên trả về thành công khi tất cả các trường bắt buộc đều hợp lệ', () {
      // ARRANGE: Tạo một state với đầy đủ thông tin
      final itemState = const ItemDetailState(
        name: 'Áo thun trắng',
        selectedClosetId: 'closet1',
        selectedCategoryValue: 'category_tops > category_tops_tshirts',
      );

      // ACT: Gọi hàm execute
      final result = useCase.executeForSingle(itemState);

      // ASSERT: Kiểm tra kết quả
      expect(result.success, isTrue);
      expect(result.errorCode, isNull);
    });

    test('Nên trả về thất bại với mã lỗi "name_required" khi tên trống', () {
      // ARRANGE: State thiếu tên
      final itemState = const ItemDetailState(
        name: ' ', // Tên chỉ chứa khoảng trắng
        selectedClosetId: 'closet1',
        selectedCategoryValue: 'category_tops > category_tops_tshirts',
      );

      // ACT
      final result = useCase.executeForSingle(itemState);

      // ASSERT
      expect(result.success, isFalse);
      expect(result.errorCode, 'name_required');
    });

    test('Nên trả về thất bại với mã lỗi "closet_required" khi chưa chọn tủ đồ', () {
      // ARRANGE: State thiếu closetId
      final itemState = const ItemDetailState(
        name: 'Áo thun trắng',
        selectedClosetId: null,
        selectedCategoryValue: 'category_tops > category_tops_tshirts',
      );

      // ACT
      final result = useCase.executeForSingle(itemState);

      // ASSERT
      expect(result.success, isFalse);
      expect(result.errorCode, 'closet_required');
    });

    test('Nên trả về thất bại với mã lỗi "category_required" khi chưa chọn danh mục', () {
      // ARRANGE: State thiếu category
      final itemState = const ItemDetailState(
        name: 'Áo thun trắng',
        selectedClosetId: 'closet1',
        selectedCategoryValue: '', // Danh mục trống
      );

      // ACT
      final result = useCase.executeForSingle(itemState);

      // ASSERT
      expect(result.success, isFalse);
      expect(result.errorCode, 'category_required');
    });
  });
}