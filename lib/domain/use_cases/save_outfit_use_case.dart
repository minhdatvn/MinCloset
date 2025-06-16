// lib/domain/use_cases/save_outfit_use_case.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class SaveOutfitUseCase {
  final OutfitRepository _outfitRepo;

  SaveOutfitUseCase(this._outfitRepo);

  // Phương thức execute nhận tất cả dữ liệu cần thiết
  Future<void> execute({
    required String name,
    required Map<String, ClothingItem> itemsOnCanvas,
    required Uint8List capturedImage,
  }) async {
    // Di chuyển toàn bộ logic lưu trữ từ Notifier vào đây
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = p.join(directory.path, '${const Uuid().v4()}.png');
    await File(imagePath).writeAsBytes(capturedImage);

    final itemIds = itemsOnCanvas.values.map((item) => item.id).join(',');

    final newOutfit = Outfit(
      id: const Uuid().v4(),
      name: name,
      imagePath: imagePath,
      itemIds: itemIds,
    );

    // Gọi đến Repository để lưu vào CSDL
    await _outfitRepo.insertOutfit(newOutfit);
  }
}