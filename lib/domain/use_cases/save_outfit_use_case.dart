// lib/domain/use_cases/save_outfit_use_case.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/utils/logger.dart'; // <<< THÊM IMPORT NÀY
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class SaveOutfitUseCase {
  final OutfitRepository _outfitRepo;

  SaveOutfitUseCase(this._outfitRepo);

  Future<void> execute({
    required String name,
    required bool isFixed,
    required Map<String, ClothingItem> itemsOnCanvas,
    required Uint8List capturedImage,
  }) async {
    // --- BƯỚC 1: LƯU ẢNH VÀO BỘ NHỚ ---
    final String imagePath;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.png';
      imagePath = p.join(directory.path, fileName);
      
      // Bọc thao tác ghi file trong try-catch để bắt lỗi cụ thể
      await File(imagePath).writeAsBytes(capturedImage);
      logger.i('Successfully saved outfit photo at: $imagePath');

    } catch (e, s) {
      // Ghi lại lỗi chi tiết nếu có sự cố xảy ra khi ghi file
      logger.e('File write error when saving outfit', error: e, stackTrace: s);
      // Ném ra một lỗi mới rõ ràng hơn để tầng Notifier có thể bắt được
      throw Exception('Could not save outfit photo. Please try again.');
    }

    // --- BƯỚC 2: TẠO ĐỐI TƯỢNG OUTFIT VÀ LƯU VÀO CSDL ---
    final itemIds = itemsOnCanvas.values.map((item) => item.id).join(',');

    final newOutfit = Outfit(
      id: const Uuid().v4(),
      name: name,
      imagePath: imagePath,
      itemIds: itemIds,
      isFixed: isFixed,
    );
    
    // Thao tác với CSDL cũng có thể gây lỗi, nhưng thường ít hơn lỗi file
    await _outfitRepo.insertOutfit(newOutfit);
  }
}