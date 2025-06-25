import 'package:mincloset/repositories/clothing_item_repository.dart';

class MoveMultipleItemsUseCase {
  final ClothingItemRepository _repo;

  MoveMultipleItemsUseCase(this._repo);

  Future<void> execute(Set<String> ids, String targetClosetId) async {
    return _repo.moveMultipleItems(ids, targetClosetId);
  }
}