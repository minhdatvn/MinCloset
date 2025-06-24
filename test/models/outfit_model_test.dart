// test/models/outfit_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/outfit.dart';

void main() {
  group('Outfit Model', () {
    const tOutfitId = 'outfit-123';

    // <<< SỬA ĐỔI: Thêm thumbnailPath vào model mẫu >>>
    final tOutfitModel = const Outfit(
      id: tOutfitId,
      name: 'Đi Đà Lạt',
      imagePath: 'path/image.png',
      thumbnailPath: 'path/thumb.png', // Thêm vào đây
      itemIds: 'itemA,itemB',
      isFixed: true,
    );

    // <<< SỬA ĐỔI: Thêm thumbnailPath vào map mẫu >>>
    final tOutfitMap = {
      'id': tOutfitId,
      'name': 'Đi Đà Lạt',
      'imagePath': 'path/image.png',
      'thumbnailPath': 'path/thumb.png', // Thêm vào đây
      'itemIds': 'itemA,itemB',
      'is_fixed': 1,
    };

    test('Nên trả về một Map<String, dynamic> chứa dữ liệu chính xác', () {
      final result = tOutfitModel.toMap();
      expect(result, tOutfitMap);
    });

    test('Nên trả về một đối tượng Outfit hợp lệ khi Map là chính xác', () {
      final result = Outfit.fromMap(tOutfitMap);
      expect(result, tOutfitModel);
    });

    // <<< THÊM MỚI: Bài test cho trường hợp thumbnailPath là null >>>
    test('Nên xử lý chính xác khi thumbnailPath là null (tương thích ngược)', () {
      // Arrange
      final mapWithNullThumbnail = Map<String, dynamic>.from(tOutfitMap);
      mapWithNullThumbnail.remove('thumbnailPath'); // Xóa key thumbnailPath

      // Act
      final result = Outfit.fromMap(mapWithNullThumbnail);

      // Assert
      // Mong đợi thumbnailPath trong model là null
      expect(result.thumbnailPath, isNull);
      // Mong đợi các trường khác vẫn đúng
      expect(result.id, tOutfitModel.id);
    });

    test('Nên xử lý chính xác khi is_fixed là 0', () {
      final mapWithIsFixedFalse = Map<String, dynamic>.from(tOutfitMap);
      mapWithIsFixedFalse['is_fixed'] = 0;
      final result = Outfit.fromMap(mapWithIsFixedFalse);
      expect(result.isFixed, false);
    });

    test('Nên xử lý chính xác khi is_fixed bị null (tương thích ngược)', () {
      final mapWithIsFixedNull = Map<String, dynamic>.from(tOutfitMap);
      mapWithIsFixedNull.remove('is_fixed');
      final result = Outfit.fromMap(mapWithIsFixedNull);
      expect(result.isFixed, false);
    });
  });
}