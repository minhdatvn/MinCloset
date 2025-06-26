// lib/domain/use_cases/save_outfit_use_case.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/helpers/image_helper.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class SaveOutfitUseCase {
  final OutfitRepository _outfitRepo;
  final ImageHelper _imageHelper;

  SaveOutfitUseCase(this._outfitRepo, this._imageHelper);

  // <<< THAY ĐỔI: Chữ ký hàm giờ trả về Future<Either<Failure, Unit>> >>>
  Future<Either<Failure, Unit>> execute({
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
      return Left(GenericFailure('Could not save outfit photo. Please try again.'));
    }

    final String? thumbnailPath = await _imageHelper.createThumbnail(imagePath);

    final itemIds = itemsOnCanvas.values.map((item) => item.id).join(',');

    final newOutfit = Outfit(
      id: const Uuid().v4(),
      name: name,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
      itemIds: itemIds,
      isFixed: isFixed,
    );
    
    // <<< THAY ĐỔI: Trả về kết quả Either từ repository >>>
    return _outfitRepo.insertOutfit(newOutfit);
  }
}