// lib/providers/database_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';

// Provider (1): Cung cấp DatabaseHelper
// Thay vì dùng DatabaseHelper.instance ở khắp nơi, chúng ta tạo một provider
// để cung cấp nó. Điều này giúp cho việc quản lý và test sau này dễ dàng hơn.
final dbHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});


// Provider (2): Cung cấp danh sách tủ đồ
// Đây là một FutureProvider. Nó sẽ tự động xử lý việc gọi hàm bất đồng bộ
// (hàm có `async` và `await`) và cung cấp kết quả.
final closetsProvider = FutureProvider<List<Closet>>((ref) async {
  // Dùng `ref.read` để lấy ra instance của DatabaseHelper từ provider ở trên.
  final dbHelper = ref.read(dbHelperProvider);

  // Gọi hàm để lấy dữ liệu từ CSDL
  final closetsData = await dbHelper.getClosets();

  // Chuyển đổi dữ liệu từ dạng Map sang dạng List<Closet> và trả về.
  // Riverpod sẽ lo phần còn lại.
  return closetsData.map((map) => Closet.fromMap(map)).toList();
});

final itemsInClosetProvider = FutureProvider.family<List<ClothingItem>, String>((ref, closetId) async {
  final dbHelper = ref.read(dbHelperProvider);

  // Dùng tham số `closetId` để query CSDL
  final itemsData = await dbHelper.getItemsInCloset(closetId);

  return itemsData.map((item) => ClothingItem.fromMap(item)).toList();
});