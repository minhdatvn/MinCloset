// lib/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';

// Provider này sẽ tạo và cung cấp một đối tượng ClosetRepository duy nhất
// cho toàn bộ ứng dụng.
final closetRepositoryProvider = Provider<ClosetRepository>((ref) {
  // Nó đọc `dbHelperProvider` mà chúng ta đã có...
  final dbHelper = ref.watch(dbHelperProvider);
  // ...và dùng nó để tạo ra một ClosetRepository.
  return ClosetRepository(dbHelper);
});

// Sau này, bạn sẽ thêm các provider cho các repository khác vào đây, ví dụ:
// final clothingItemRepositoryProvider = Provider(...);
// final outfitRepositoryProvider = Provider(...);