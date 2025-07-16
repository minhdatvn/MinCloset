// lib/domain/use_cases/validate_item_name_use_case.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/models/validation_result.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/states/item_detail_state.dart';

class ValidateItemNameUseCase {
  final ClothingItemRepository _repo;

  ValidateItemNameUseCase(this._repo);

  Future<Either<Failure, ValidationResult>> forSingleItem({
    required String name,
    String? existingId,
  }) async {
    final allItemsEither = await _repo.getAllItems();

    return allItemsEither.fold(
      (failure) => Left(failure), // Nếu không lấy được danh sách item, trả về lỗi
      (allItems) {
        // Nếu lấy được danh sách thành công, thực hiện logic validation
        final trimmedNewName = name.trim().toLowerCase();
        final existingNames = allItems
            .where((item) => item.id != existingId)
            .map((e) => e.name.trim().toLowerCase())
            .toSet();

        if (existingNames.contains(trimmedNewName)) {
          return Right(ValidationResult.failure(
            null, // Không cần chuỗi lỗi nữa
            errorCode: 'nameTakenSingle', // <-- Trả về MÃ LỖI
            data: { 'itemName': name.trim() }, // <-- Trả về DỮ LIỆU
          ));
        }
        return Right(ValidationResult.success());
      },
    );
  }

  Future<Either<Failure, ValidationResult>> forBatch(List<ItemDetailState> itemStates) async {
    // 1. Kiểm tra trùng lặp bên trong nhóm (logic này không đổi vì không gọi repo)
    final nameTracker = <String, int>{};
    for (int i = 0; i < itemStates.length; i++) {
      final currentName = itemStates[i].name.trim();
      if (nameTracker.containsKey(currentName)) {
        final originalIndex = nameTracker[currentName]!;
        return Right(ValidationResult.failure(
          null, // Không cần chuỗi lỗi nữa
          errorIndex: i,
          errorCode: 'nameConflict', // <-- Trả về MÃ LỖI
          data: { // <-- Trả về DỮ LIỆU
            'itemName': currentName,
            'itemNumber': i + 1,
            'conflictNumber': originalIndex + 1,
          },
        ));
      }
      nameTracker[currentName] = i;
    }

    // 2. Kiểm tra trùng lặp với CSDL
    final allItemsEither = await _repo.getAllItems();
    
    return allItemsEither.fold(
      (failure) => Left(failure),
      (allItems) {
        final existingNames = allItems.map((e) => e.name.trim().toLowerCase()).toSet();
        for (int i = 0; i < itemStates.length; i++) {
          final currentName = itemStates[i].name.trim();
          if (existingNames.contains(currentName.toLowerCase())) {
            return Right(ValidationResult.failure(
              null, // Không cần chuỗi lỗi nữa
              errorIndex: i,
              errorCode: 'nameTaken', // <-- Trả về MÃ LỖI
              data: { // <-- Trả về DỮ LIỆU
                'itemName': currentName,
                'itemNumber': i + 1,
              },
            ));
          }
        }
        return Right(ValidationResult.success());
      },
    );
  }
}