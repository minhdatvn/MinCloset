// lib/notifiers/closets_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/closet.dart';
import 'package:mincloset/providers/database_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:uuid/uuid.dart';

// State của trang này rất đơn giản, chỉ cần biết loading hay có lỗi không
class ClosetsPageState {
  final bool isLoading;
  final String? error;
  const ClosetsPageState({this.isLoading = false, this.error});
}

class ClosetsPageNotifier extends StateNotifier<ClosetsPageState> {
  final ClosetRepository _closetRepo;
  final Ref _ref;

  ClosetsPageNotifier(this._closetRepo, this._ref) : super(const ClosetsPageState());

  Future<String?> addCloset(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Closet name cannot be empty.';
    }
    if (trimmedName.length > 30) {
      return 'Closet name cannot exceed 30 characters.';
    }

    state = const ClosetsPageState(isLoading: true);
    try {
      final closets = await _ref.read(closetsProvider.future);

      // Thêm logic kiểm tra giới hạn số lượng
      if (closets.length >= 10) {
        state = const ClosetsPageState(isLoading: false);
        return 'Maximum number of closets (10) reached.';
      }

      final isDuplicate = closets.any((closet) =>
          closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

      if (isDuplicate) {
        state = const ClosetsPageState(isLoading: false);
        return 'A closet with this name already exists.';
      }

      final newCloset = Closet(id: const Uuid().v4(), name: trimmedName);
      await _closetRepo.insertCloset(newCloset);

      _ref.invalidate(closetsProvider);
      state = const ClosetsPageState(isLoading: false);
      return null;
    } catch (e) {
      state = ClosetsPageState(isLoading: false, error: e.toString());
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> deleteCloset(String closetId) async {
    try {
      // Lấy danh sách các repo từ ref
      final closetRepo = _ref.read(closetRepositoryProvider);
      final clothingItemRepo = _ref.read(clothingItemRepositoryProvider);

      // Kiểm tra xem closet có trống không
      final itemsInCloset = await clothingItemRepo.getItemsInCloset(closetId);
      if (itemsInCloset.isNotEmpty) {
        return 'Closet is not empty. Move or delete items first.';
      }

      // Nếu closet trống, tiến hành xóa
      await closetRepo.deleteCloset(closetId);
      _ref.invalidate(closetsProvider); // Cập nhật lại danh sách closets
      return null; // Xóa thành công
    } catch (e) {
      return 'An unexpected error occurred during deletion.';
    }
  }

  Future<String?> updateCloset(Closet closetToUpdate, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return 'Closet name cannot be empty.';
    }
    if (trimmedName.length > 30) {
      return 'Closet name cannot exceed 30 characters.';
    }

    try {
      final closets = await _ref.read(closetsProvider.future);
      // Kiểm tra xem tên mới có trùng với một closet *khác* không
      final isDuplicate = closets.any((closet) =>
          closet.id != closetToUpdate.id &&
          closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

      if (isDuplicate) {
        return 'A closet with this name already exists.';
      }

      // Cập nhật closet
      await _closetRepo.updateCloset(closetToUpdate.copyWith(name: trimmedName));
      _ref.invalidate(closetsProvider); // Tải lại danh sách
      return null; // Thành công
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }
}

// Tạo provider cho notifier mới
final closetsPageProvider = StateNotifierProvider.autoDispose<ClosetsPageNotifier, ClosetsPageState>((ref) {
  final repo = ref.watch(closetRepositoryProvider);
  return ClosetsPageNotifier(repo, ref);
});