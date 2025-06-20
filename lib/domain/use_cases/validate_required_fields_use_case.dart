// lib/domain/use_cases/validate_required_fields_use_case.dart

import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/states/add_item_state.dart';

class ValidateRequiredFieldsUseCase {
  /// Xác thực các trường bắt buộc cho một món đồ duy nhất.
  ValidationResult executeForSingle(AddItemState itemState) {
    if (itemState.name.trim().isEmpty) {
      return ValidationResult.failure("Vui lòng nhập tên");
    }
    if (itemState.selectedClosetId == null) {
      return ValidationResult.failure("Vui lòng chọn tủ quần áo");
    }
    if (itemState.selectedCategoryValue.isEmpty) {
      return ValidationResult.failure("Vui lòng chọn danh mục");
    }
    return ValidationResult.success();
  }

  /// Xác thực các trường bắt buộc cho một danh sách các món đồ.
  ValidationResult executeForBatch(List<AddItemState> itemStates) {
    for (int i = 0; i < itemStates.length; i++) {
      final itemState = itemStates[i];
      if (itemState.name.trim().isEmpty) {
        return ValidationResult.failure(
          "Vui lòng nhập tên cho Món đồ số ${i + 1}",
          errorIndex: i,
        );
      }
      if (itemState.selectedClosetId == null) {
        return ValidationResult.failure(
          "Vui lòng chọn tủ quần áo cho Món đồ số ${i + 1}",
          errorIndex: i,
        );
      }
      if (itemState.selectedCategoryValue.isEmpty) {
        return ValidationResult.failure(
          "Vui lòng chọn danh mục cho Món đồ số ${i + 1}",
          errorIndex: i,
        );
      }
    }
    return ValidationResult.success();
  }
}