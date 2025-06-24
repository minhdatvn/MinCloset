// lib/domain/use_cases/validate_item_name_use_case.dart

import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';

class ValidateItemNameUseCase {
  final ClothingItemRepository _repo;

  ValidateItemNameUseCase(this._repo);

  /// Xác thực tên cho một món đồ duy nhất (thêm mới hoặc chỉnh sửa).
  /// [existingId] chỉ được truyền vào khi ở chế độ chỉnh sửa.
  Future<ValidationResult> forSingleItem({
    required String name,
    String? existingId,
  }) async {
    final allItems = await _repo.getAllItems();
    final trimmedNewName = name.trim().toLowerCase();

    // Lọc ra danh sách tên đã tồn tại, loại trừ chính nó khi sửa
    final existingNames = allItems
        .where((item) => item.id != existingId)
        .map((e) => e.name.trim().toLowerCase())
        .toSet();

    if (existingNames.contains(trimmedNewName)) {
      return ValidationResult.failure(
        '"${name.trim()}" is already taken. Please use a different name. You can add numbers to distinguish items (e.g., Shirt 1, Shirt 2...).',
      );
    }

    return ValidationResult.success();
  }

  /// Xác thực tên cho một danh sách các món đồ (thêm hàng loạt).
  Future<ValidationResult> forBatch(List<AddItemState> itemStates) async {
    // 1. Kiểm tra trùng lặp bên trong nhóm
    final nameTracker = <String, int>{};
    for (int i = 0; i < itemStates.length; i++) {
      final currentName = itemStates[i].name.trim();
      if (nameTracker.containsKey(currentName)) {
        final originalIndex = nameTracker[currentName]!;
        return ValidationResult.failure(
          '"$currentName" for item ${i + 1}  is already used by item ${originalIndex + 1}. Please use a different name. You can add numbers to distinguish items (e.g., Shirt 1, Shirt 2...).',
          errorIndex: i,
        );
      }
      nameTracker[currentName] = i;
    }

    // 2. Kiểm tra trùng lặp với CSDL
    final allItems = await _repo.getAllItems();
    final existingNames = allItems.map((e) => e.name.trim().toLowerCase()).toSet();

    for (int i = 0; i < itemStates.length; i++) {
      final currentName = itemStates[i].name.trim();
      if (existingNames.contains(currentName.toLowerCase())) {
        return ValidationResult.failure(
          '"$currentName" for item ${i + 1} is already taken. Please use a different name. You can add numbers to distinguish items (e.g., Shirt 1, Shirt 2...).',
          errorIndex: i,
        );
      }
    }

    return ValidationResult.success();
  }
}