// lib/domain/use_cases/validate_required_fields_use_case.dart

import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/states/item_detail_state.dart';

class ValidateRequiredFieldsUseCase {
  /// Xác thực các trường bắt buộc cho một món đồ duy nhất.
  ValidationResult executeForSingle(ItemDetailState itemState) {
    if (itemState.name.trim().isEmpty) {
      return ValidationResult.failure("Please enter item name");
    }
    if (itemState.selectedClosetId == null) {
      return ValidationResult.failure("Please select a closet");
    }
    if (itemState.selectedCategoryValue.isEmpty) {
      return ValidationResult.failure("Please select a category");
    }
    return ValidationResult.success();
  }

  /// Xác thực các trường bắt buộc cho một danh sách các món đồ.
  ValidationResult executeForBatch(List<ItemDetailState> itemStates) {
    for (int i = 0; i < itemStates.length; i++) {
      final itemState = itemStates[i];
      if (itemState.name.trim().isEmpty) {
        return ValidationResult.failure(
          "Please enter a name for Item ${i + 1}",
          errorIndex: i,
        );
      }
      if (itemState.selectedClosetId == null) {
        return ValidationResult.failure(
          "Please select a closet for Item ${i + 1}",
          errorIndex: i,
        );
      }
      if (itemState.selectedCategoryValue.isEmpty) {
        return ValidationResult.failure(
          "Please select a category for Item ${i + 1}",
          errorIndex: i,
        );
      }
    }
    return ValidationResult.success();
  }
}