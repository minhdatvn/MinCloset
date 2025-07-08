// lib/helpers/image_helper.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:mincloset/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// <<< TẠO LỚP MỚI >>>
class ImageHelper {
  Future<String?> createThumbnail(String sourcePath) async {
    try {
      final imageFile = File(sourcePath);
      if (!await imageFile.exists()) {
        logger.w('Source image not found at $sourcePath');
        return null;
      }
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        logger.w('Could not decode image at $sourcePath');
        return null;
      }
      final thumbnail = img.copyResize(image, width: 300);
      // 1. Mã hóa thành PNG thay vì JPG
      final pngBytes = img.encodePng(thumbnail);

      final directory = await getApplicationDocumentsDirectory();
      // 2. Lưu file với đuôi .png
      final fileName = 'thumb_${const Uuid().v4()}.png';
      final thumbnailPath = p.join(directory.path, fileName);
      
      // 3. Ghi dữ liệu PNG vào file
      await File(thumbnailPath).writeAsBytes(pngBytes);
      
      logger.i('Thumbnail created at: $thumbnailPath');
      return thumbnailPath;
    } catch (e, s) {
      logger.e('Error creating thumbnail', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> deleteImageAndThumbnail({
    required String? imagePath,
    required String? thumbnailPath,
  }) async {
    if (imagePath != null) {
      try {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          logger.i('Deleted image file: $imagePath');
        }
      } catch (e) {
        logger.e('Error deleting image file: $imagePath', error: e);
      }
    }
    if (thumbnailPath != null) {
      try {
        final thumbFile = File(thumbnailPath);
        if (await thumbFile.exists()) {
          await thumbFile.delete();
          logger.i('Deleted thumbnail file: $thumbnailPath');
        }
      } catch (e) {
        logger.e('Error deleting thumbnail file: $thumbnailPath', error: e);
      }
    }
  }
}

// <<< TẠO PROVIDER CHO LỚP MỚI >>>
final imageHelperProvider = Provider((ref) => ImageHelper());