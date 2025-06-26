// lib/domain/use_cases/delete_multiple_items_use_case.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';

class DeleteMultipleItemsUseCase {
  final ClothingItemRepository _repo;

  DeleteMultipleItemsUseCase(this._repo);

  // <<< THAY ĐỔI: Chữ ký hàm giờ trả về Future<Either<Failure, Unit>> >>>
  Future<Either<Failure, Unit>> execute(Set<String> ids) async {
    return _repo.deleteMultipleItems(ids);
  }
}