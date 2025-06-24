// lib/helpers/image_helper.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mincloset/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Tạo một ảnh thu nhỏ từ ảnh gốc.
///
/// [sourcePath] Đường dẫn đến file ảnh gốc.
/// Trả về đường dẫn đến file ảnh thu nhỏ đã tạo, hoặc null nếu có lỗi.
Future<String?> createThumbnail(String sourcePath) async {
  try {
    // 1. Đọc file ảnh gốc
    final imageFile = File(sourcePath);
    if (!await imageFile.exists()) {
      logger.w('Source image not found at $sourcePath');
      return null;
    }
    final Uint8List imageBytes = await imageFile.readAsBytes();

    // 2. Giải mã (decode) dữ liệu ảnh
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      logger.w('Could not decode image at $sourcePath');
      return null;
    }

    // 3. Thay đổi kích thước ảnh với chiều rộng cố định là 300px
    // Chiều cao sẽ tự động được điều chỉnh để giữ đúng tỷ lệ
    final thumbnail = img.copyResize(image, width: 300);

    // 4. Mã hóa (encode) ảnh thu nhỏ thành định dạng JPEG với chất lượng 85%
    final jpgBytes = img.encodeJpg(thumbnail, quality: 85);

    // 5. Lấy thư mục lưu trữ của ứng dụng và tạo tên file mới
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'thumb_${const Uuid().v4()}.jpg';
    final thumbnailPath = p.join(directory.path, fileName);

    // 6. Lưu file ảnh thu nhỏ
    await File(thumbnailPath).writeAsBytes(jpgBytes);

    logger.i('Thumbnail created at: $thumbnailPath');
    return thumbnailPath;
  } catch (e, s) {
    logger.e('Error creating thumbnail', error: e, stackTrace: s);
    return null; // Trả về null nếu có bất kỳ lỗi nào xảy ra
  }
}

/// Xóa an toàn file ảnh gốc và ảnh thu nhỏ nếu chúng tồn tại.
Future<void> deleteImageAndThumbnail({
  required String? imagePath,
  required String? thumbnailPath,
}) async {
  // Xóa ảnh gốc
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

  // Xóa ảnh thu nhỏ
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