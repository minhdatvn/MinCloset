// lib/providers/database_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/helpers/db_helper.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/models/clothing_item.dart';

// <<< THÊM IMPORT MỚI cho file repository provider
import 'package:mincloset/providers/repository_providers.dart';

// Provider này vẫn giữ nguyên, vì Repository cần nó để hoạt động
final dbHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Provider cung cấp danh sách tủ đồ
final closetsProvider = FutureProvider<List<Closet>>((ref) {
  // <<< THAY ĐỔI Ở ĐÂY
  // Thay vì đọc dbHelper, nó đọc closetRepository...
  final closetRepository = ref.watch(closetRepositoryProvider);
  // ...và gọi phương thức tương ứng.
  // Notifier giờ đây không cần biết dữ liệu đến từ đâu.
  return closetRepository.getClosets();
});

// Provider cung cấp danh sách các vật phẩm trong một tủ đồ cụ thể
final itemsInClosetProvider =
    FutureProvider.family<List<ClothingItem>, String>((ref, closetId) async {
  // Tạm thời vẫn dùng dbHelper trực tiếp, bạn sẽ refactor phần này sau
  // khi tạo ClothingItemRepository
  final dbHelper = ref.read(dbHelperProvider);
  final itemsData = await dbHelper.getItemsInCloset(closetId);
  return itemsData.map((item) => ClothingItem.fromMap(item)).toList();
});