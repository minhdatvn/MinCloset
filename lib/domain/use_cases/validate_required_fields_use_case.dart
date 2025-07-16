// lib/domain/use_cases/validate_required_fields_use_case.dart

import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/states/item_detail_state.dart';

class ValidateRequiredFieldsUseCase {
  /// Xác thực các trường bắt buộc cho một món đồ duy nhất.
  ValidationResult executeForSingle(ItemDetailState itemState) {
    if (itemState.name.trim().isEmpty) {
      return ValidationResult.failure(null, errorCode: 'name_required');
    }
    if (itemState.selectedClosetId == null) {
      return ValidationResult.failure(null, errorCode: 'closet_required');
    }
    if (itemState.selectedCategoryValue.isEmpty) {
      return ValidationResult.failure(null, errorCode: 'category_required');
    }
    return ValidationResult.success();
  }

  /// Xác thực các trường bắt buộc cho một danh sách các món đồ.
  ValidationResult executeForBatch(List<ItemDetailState> itemStates) {
    for (int i = 0; i < itemStates.length; i++) {
      final itemState = itemStates[i];
      if (itemState.name.trim().isEmpty) {
        return ValidationResult.failure(
          null,
          errorIndex: i,
          errorCode: 'batch_name_required',
          data: {'itemNumber': i + 1},
        );
      }
      if (itemState.selectedClosetId == null) {
        return ValidationResult.failure(
          null,
          errorIndex: i,
          errorCode: 'batch_closet_required',
          data: {'itemNumber': i + 1},
        );
      }
      if (itemState.selectedCategoryValue.isEmpty) {
        return ValidationResult.failure(
          null,
          errorIndex: i,
          errorCode: 'batch_category_required',
          data: {'itemNumber': i + 1},
        );
      }
    }
    return ValidationResult.success();
  }
}