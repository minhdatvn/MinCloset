import 'package:mincloset/repositories/clothing_item_repository.dart';

class DeleteMultipleItemsUseCase {
  final ClothingItemRepository _repo;

  DeleteMultipleItemsUseCase(this._repo);

  Future<void> execute(Set<String> ids) async {
    return _repo.deleteMultipleItems(ids);
  }
}