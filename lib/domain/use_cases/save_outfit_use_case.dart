// lib/domain/use_cases/save_outfit_use_case.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:mincloset/helpers/image_helper.dart'; // Sửa import
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class SaveOutfitUseCase {
  final OutfitRepository _outfitRepo;
  final ImageHelper _imageHelper; // <<< Thêm dependency

  // <<< Sửa constructor >>>
  SaveOutfitUseCase(this._outfitRepo, this._imageHelper);

  Future<void> execute({
    required String name,
    required bool isFixed,
    required Map<String, ClothingItem> itemsOnCanvas,
    required Uint8List capturedImage,
  }) async {
    final String imagePath;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.png';
      imagePath = p.join(directory.path, fileName);
      
      await File(imagePath).writeAsBytes(capturedImage);
      logger.i('Successfully saved outfit photo at: $imagePath');

    } catch (e, s) {
      logger.e('File write error when saving outfit', error: e, stackTrace: s);
      throw Exception('Could not save outfit photo. Please try again.');
    }

    // <<< THÊM MỚI: TẠO ẢNH THU NHỎ >>>
    final String? thumbnailPath = await _imageHelper.createThumbnail(imagePath);

    // --- TẠO ĐỐI TƯỢNG OUTFIT VÀ LƯU VÀO CSDL ---
    final itemIds = itemsOnCanvas.values.map((item) => item.id).join(',');

    final newOutfit = Outfit(
      id: const Uuid().v4(),
      name: name,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath, // Gán đường dẫn ảnh thu nhỏ
      itemIds: itemIds,
      isFixed: isFixed,
    );
    
    await _outfitRepo.insertOutfit(newOutfit);
  }
}