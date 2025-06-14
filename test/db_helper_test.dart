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

  // Dọn dẹp CSDL trước mỗi bài test
  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('clothing_items');
    await db.delete('closets');
  });

  group('Closet DB Tests', () {
    test('Nên thêm một tủ đồ mới vào CSDL', () async {
      // 1. ARRANGE
      final newCloset = Closet(id: const Uuid().v4(), name: 'Tủ đồ Mùa hè');

      // 2. ACT
      // Sửa lại lệnh gọi hàm
      await DatabaseHelper.instance.insertCloset(newCloset.toMap());
      final closetsData = await DatabaseHelper.instance.getClosets();
      final closets = closetsData.map((map) => Closet.fromMap(map)).toList();

      // 3. ASSERT
      expect(closets.length, 1);
      expect(closets.first.name, 'Tủ đồ Mùa hè');
    });

    test('Nên cập nhật tên của một tủ đồ', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final originalCloset = Closet(id: closetId, name: 'Tủ đồ cũ');
      await DatabaseHelper.instance.insertCloset(originalCloset.toMap());

      // Act
      final updatedCloset = Closet(id: closetId, name: 'Tủ đồ mới tinh');
      await DatabaseHelper.instance.updateCloset(updatedCloset);
      final closetsData = await DatabaseHelper.instance.getClosets();
      final closets = closetsData.map((map) => Closet.fromMap(map)).toList();

      // Assert
      expect(closets.length, 1);
      expect(closets.first.name, 'Tủ đồ mới tinh');
    });

    test('Nên xóa một tủ đồ và tất cả các món đồ bên trong', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final closet = Closet(id: closetId, name: 'Tủ đồ sắp xóa');
      final item1 = ClothingItem(id: const Uuid().v4(), name: 'Áo thun', category: 'Áo', color: 'Trắng', imagePath: 'path/to/image', closetId: closetId);
      
      await DatabaseHelper.instance.insertCloset(closet.toMap());
      await DatabaseHelper.instance.insertItem(item1.toMap());
      
      // Act
      await DatabaseHelper.instance.deleteCloset(closetId);
      final remainingClosets = await DatabaseHelper.instance.getClosets();
      final remainingItems = await DatabaseHelper.instance.getAllItems(); // Sử dụng hàm mới

      // Assert
      expect(remainingClosets.isEmpty, isTrue);
      expect(remainingItems.isEmpty, isTrue);
    });
  });

  group('ClothingItem DB Tests', () {
    test('Nên thêm một món đồ và lấy ra đúng từ tủ đồ của nó', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final closet = Closet(id: closetId, name: 'Tủ áo');
      final item = ClothingItem(id: const Uuid().v4(), name: 'Áo Polo', category: 'Áo', color: 'Đen', imagePath: 'path/to/polo', closetId: closetId);

      await DatabaseHelper.instance.insertCloset(closet.toMap());
      await DatabaseHelper.instance.insertItem(item.toMap());

      // Act
      final itemsData = await DatabaseHelper.instance.getItemsInCloset(closetId);
      final itemsInCloset = itemsData.map((map) => ClothingItem.fromMap(map)).toList();

      // Assert
      expect(itemsInCloset.length, 1);
      expect(itemsInCloset.first.name, 'Áo Polo');
    });

     test('Nên xóa một món đồ', () async {
      // Arrange
      final closetId = const Uuid().v4();
      final itemId = const Uuid().v4();
      final item = ClothingItem(id: itemId, name: 'Áo sắp xóa', category: 'Áo', color: 'Đỏ', imagePath: 'path/to/item', closetId: closetId);
      await DatabaseHelper.instance.insertItem(item.toMap());

      // Act
      await DatabaseHelper.instance.deleteItem(itemId);
      final remainingItems = await DatabaseHelper.instance.getAllItems();

      // Assert
      expect(remainingItems.isEmpty, isTrue);
    });
  });
}