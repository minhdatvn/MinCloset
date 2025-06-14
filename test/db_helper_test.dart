// file: test/db_helper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  // Cài đặt môi trường FFI cho sqflite
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // === HÀM DỌN DẸP, CHẠY TRƯỚC MỖI BÀI TEST ===
  setUp(() async {
    // Xóa sạch dữ liệu trong các bảng trước mỗi bài test
    // để đảm bảo các bài test độc lập với nhau
    final db = await DBHelper.db();
    await db.delete('clothing_items');
    await db.delete('closets');
  });
  // ===============================================

  group('Closet DB Tests', () {
    test('Nên thêm một tủ đồ mới vào CSDL', () async {
      // 1. ARRANGE (Sắp xếp)
      final newCloset = Closet(id: const Uuid().v4(), name: 'Tủ đồ Mùa hè');

      // 2. ACT (Hành động)
      await DBHelper.insertCloset('closets', newCloset.toMap());
      final closets = await DBHelper.getClosets('closets');

      // 3. ASSERT (Kiểm chứng)
      expect(closets.length, 1);
      expect(closets.first['name'], 'Tủ đồ Mùa hè');
    });

    test('Nên cập nhật tên của một tủ đồ', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final originalCloset = Closet(id: closetId, name: 'Tủ đồ cũ');
      await DBHelper.insertCloset('closets', originalCloset.toMap());

      // Act
      final updatedCloset = Closet(id: closetId, name: 'Tủ đồ mới tinh');
      await DBHelper.updateCloset(updatedCloset);
      final closets = await DBHelper.getClosets('closets');

      // Assert
      expect(closets.length, 1); // Bây giờ chỉ có 1 tủ đồ trong CSDL
      expect(closets.first['name'], 'Tủ đồ mới tinh');
    });

    test('Nên xóa một tủ đồ và tất cả các món đồ bên trong', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final closet = Closet(id: closetId, name: 'Tủ đồ sắp xóa');
      final item1 = ClothingItem(id: const Uuid().v4(), name: 'Áo thun', category: 'Áo', color: 'Trắng', imagePath: 'path/to/image', closetId: closetId);
      final item2 = ClothingItem(id: const Uuid().v4(), name: 'Quần short', category: 'Quần', color: 'Xanh', imagePath: 'path/to/image2', closetId: closetId);

      await DBHelper.insertCloset('closets', closet.toMap());
      await DBHelper.insert('clothing_items', item1.toMap());
      await DBHelper.insert('clothing_items', item2.toMap());
      
      // Act
      await DBHelper.deleteCloset(closetId);
      final remainingClosets = await DBHelper.getClosets('closets');
      final remainingItems = await DBHelper.getData('clothing_items');

      // Assert
      expect(remainingClosets.isEmpty, isTrue);
      expect(remainingItems.isEmpty, isTrue);
    });
  });

  // Nhóm các bài test liên quan đến Món đồ (ClothingItem)
  group('ClothingItem DB Tests', () {
    test('Nên thêm một món đồ và lấy ra đúng từ tủ đồ của nó', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final closet = Closet(id: closetId, name: 'Tủ áo');
      final item = ClothingItem(id: const Uuid().v4(), name: 'Áo Polo', category: 'Áo', color: 'Đen', imagePath: 'path/to/polo', closetId: closetId);

      await DBHelper.insertCloset('closets', closet.toMap());
      await DBHelper.insert('clothing_items', item.toMap());

      // Act
      final itemsInCloset = await DBHelper.getItemsInCloset(closetId);

      // Assert
      expect(itemsInCloset.length, 1);
      expect(itemsInCloset.first['name'], 'Áo Polo');
    });

     test('Nên xóa một món đồ', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final itemId = const Uuid().v4();
      final item = ClothingItem(id: itemId, name: 'Áo sắp xóa', category: 'Áo', color: 'Đỏ', imagePath: 'path/to/item', closetId: closetId);
      await DBHelper.insert('clothing_items', item.toMap());

      // Act
      await DBHelper.deleteItem(itemId);
      final remainingItems = await DBHelper.getItemsInCloset(closetId);

      // Assert
      expect(remainingItems.isEmpty, isTrue);
    });
  });
}