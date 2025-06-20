// lib/domain/use_cases/validate_item_name_use_case.dart

import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/add_item_state.dart';
import 'package:mincloset/domain/models/validation_result.dart';

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
        'Tên "${name.trim()}" đã được dùng. Bạn vui lòng nhập tên khác. Có thể thêm số vào sau tên đồ vật (ví dụ: Áo 1, Áo 2,... để phân biệt).',
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
          'Tên "$currentName" của món đồ ${i + 1} đã trùng với món đồ ${originalIndex + 1}. Bạn vui lòng nhập tên khác. Có thể thêm số vào sau tên (ví dụ: Áo 1, Áo 2,... để dễ phân biệt).',
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
          'Tên "$currentName" của món đồ ${i + 1} đã được dùng. Bạn vui lòng nhập tên khác. Có thể thêm số vào sau tên đồ vật (ví dụ: Áo 1, Áo 2,... để phân biệt).',
          errorIndex: i,
        );
      }
    }

    return ValidationResult.success();
  }
}