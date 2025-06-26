// lib/domain/use_cases/move_multiple_items_use_case.dart

import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';

class MoveMultipleItemsUseCase {
  final ClothingItemRepository _repo;

  MoveMultipleItemsUseCase(this._repo);

  // <<< THAY ĐỔI: Chữ ký hàm giờ trả về Future<Either<Failure, Unit>> >>>
  Future<Either<Failure, Unit>> execute(Set<String> ids, String targetClosetId) async {
    return _repo.moveMultipleItems(ids, targetClosetId);
  }
}