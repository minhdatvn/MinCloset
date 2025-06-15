// lib/repositories/closet_repository.dart

import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';

// Lớp này là lớp trung gian, chịu trách nhiệm về dữ liệu Closet.
class ClosetRepository {
  // Nó phụ thuộc vào DatabaseHelper, nhưng chỉ là chi tiết triển khai bên trong.
  final DatabaseHelper _dbHelper;

  // Constructor yêu cầu một DatabaseHelper (dependency injection).
  ClosetRepository(this._dbHelper);

  // Phương thức này lấy danh sách tủ đồ.
  // Logic của nó chỉ đơn giản là gọi đến dbHelper tương ứng.
  Future<List<Closet>> getClosets() async {
    final data = await _dbHelper.getClosets();
    return data.map((map) => Closet.fromMap(map)).toList();
  }

  // Tương tự cho các phương thức khác.
  // Chúng ta di chuyển logic "giao tiếp với CSDL" vào đây.

  Future<void> insertCloset(Closet closet) async {
    await _dbHelper.insertCloset(closet.toMap());
  }

  Future<void> updateCloset(Closet closet) async {
    await _dbHelper.updateCloset(closet);
  }

  Future<void> deleteCloset(String id) async {
    await _dbHelper.deleteCloset(id);
  }
}