// test/models/outfit_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/models/outfit.dart'; // <<< Import lớp Outfit cần test

void main() {
  // Sử dụng group để nhóm các bài test liên quan đến Outfit model
  group('Outfit Model', () {
    // Dữ liệu mẫu để sử dụng trong các bài test
    const tOutfitId = 'outfit-123';
    final tOutfitModel = const Outfit(
      id: tOutfitId,
      name: 'Đi Đà Lạt',
      imagePath: 'path/image.png',
      itemIds: 'itemA,itemB',
      isFixed: true, // isFixed là true
    );

    final tOutfitMap = {
      'id': tOutfitId,
      'name': 'Đi Đà Lạt',
      'imagePath': 'path/image.png',
      'itemIds': 'itemA,itemB',
      'is_fixed': 1, // isFixed được lưu trong DB là 1
    };

    // --- Bài test cho phương thức toMap() ---
    test('Nên trả về một Map<String, dynamic> chứa dữ liệu chính xác', () {
      // Hành động (Act)
      final result = tOutfitModel.toMap();

      // Kiểm chứng (Assert)
      // mong đợi kết quả trả về sẽ giống hệt với map mẫu
      expect(result, tOutfitMap);
    });

    // --- Bài test cho phương thức fromMap() ---
    test('Nên trả về một đối tượng Outfit hợp lệ khi Map là chính xác', () {
      // Hành động (Act)
      final result = Outfit.fromMap(tOutfitMap);

      // Kiểm chứng (Assert)
      // mong đợi đối tượng được tạo ra sẽ giống hệt model mẫu
      expect(result, tOutfitModel);
    });

    test('Nên xử lý chính xác khi is_fixed là 0', () {
      // Sắp xếp (Arrange)
      // Tạo một map mới với is_fixed = 0
      final mapWithIsFixedFalse = Map<String, dynamic>.from(tOutfitMap);
      mapWithIsFixedFalse['is_fixed'] = 0;

      // Hành động (Act)
      final result = Outfit.fromMap(mapWithIsFixedFalse);

      // Kiểm chứng (Assert)
      // Thuộc tính isFixed của đối tượng kết quả phải là false
      expect(result.isFixed, false);
    });

    test('Nên xử lý chính xác khi is_fixed bị null (tương thích ngược)', () {
      // Sắp xếp (Arrange)
      // Logic trong model của bạn `(map['is_fixed'] as int? ?? 0) == 1`
      // nên xử lý được trường hợp này.
      final mapWithIsFixedNull = Map<String, dynamic>.from(tOutfitMap);
      mapWithIsFixedNull.remove('is_fixed'); // Xóa key 'is_fixed'

      // Hành động (Act)
      final result = Outfit.fromMap(mapWithIsFixedNull);

      // Kiểm chứng (Assert)
      // Thuộc tính isFixed phải là false theo logic fallback `?? 0`
      expect(result.isFixed, false);
    });
  });
}