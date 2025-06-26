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

  ClosetsPageState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ClosetsPageState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ClosetsPageNotifier extends StateNotifier<ClosetsPageState> {
  final ClosetRepository _closetRepo;
  final Ref _ref;

  ClosetsPageNotifier(this._closetRepo, this._ref) : super(const ClosetsPageState());

  // <<< THAY ĐỔI 1: Cập nhật hàm addCloset >>>
  Future<String?> addCloset(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Closet name cannot be empty.';
    }
    if (trimmedName.length > 30) {
      return 'Closet name cannot exceed 30 characters.';
    }

    state = state.copyWith(isLoading: true);

    // Dùng .future sẽ tự động xử lý lỗi của FutureProvider
    final closets = await _ref.read(closetsProvider.future);
    if (!mounted) return null;

    if (closets.length >= 10) {
      state = state.copyWith(isLoading: false);
      return 'Maximum number of closets (10) reached.';
    }

    final isDuplicate = closets.any((closet) =>
        closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

    if (isDuplicate) {
      state = state.copyWith(isLoading: false);
      return 'A closet with this name already exists.';
    }

    final newCloset = Closet(id: const Uuid().v4(), name: trimmedName);
    final result = await _closetRepo.insertCloset(newCloset);

    if (!mounted) return null;
    
    state = state.copyWith(isLoading: false);
    
    return result.fold(
      (failure) => failure.message, // Trả về thông báo lỗi nếu thất bại
      (_) {
        _ref.invalidate(closetsProvider); // Làm mới danh sách
        return null; // Trả về null nếu thành công
      },
    );
  }

  // <<< THAY ĐỔI 2: Cập nhật hàm updateCloset >>>
  Future<String?> updateCloset(Closet closetToUpdate, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      return 'Closet name cannot be empty.';
    }
    if (trimmedName.length > 30) {
      return 'Closet name cannot exceed 30 characters.';
    }

    final closets = await _ref.read(closetsProvider.future);
    if (!mounted) return null;

    final isDuplicate = closets.any((closet) =>
        closet.id != closetToUpdate.id &&
        closet.name.trim().toLowerCase() == trimmedName.toLowerCase());

    if (isDuplicate) {
      return 'A closet with this name already exists.';
    }
    
    final result = await _closetRepo.updateCloset(closetToUpdate.copyWith(name: trimmedName));
    
    if (!mounted) return null;

    return result.fold(
      (failure) => failure.message,
      (_) {
        _ref.invalidate(closetsProvider);
        return null;
      },
    );
  }

  // <<< THAY ĐỔI 3: Cập nhật hàm deleteCloset >>>
  Future<String?> deleteCloset(String closetId) async {
    final clothingItemRepo = _ref.read(clothingItemRepositoryProvider);
    final itemsResult = await clothingItemRepo.getItemsInCloset(closetId);

    if (!mounted) return null;

    // Xử lý kết quả Either từ getItemsInCloset
    final itemsInCloset = itemsResult.getOrElse((_) => []);
    if (itemsInCloset.isNotEmpty) {
      return 'Closet is not empty. Move or delete items first.';
    }

    // Nếu closet trống, tiến hành xóa
    final deleteResult = await _closetRepo.deleteCloset(closetId);
    
    if (!mounted) return null;
    
    return deleteResult.fold(
      (failure) => failure.message,
      (_) {
        _ref.invalidate(closetsProvider);
        return null;
      },
    );
  }
}

final closetsPageProvider = StateNotifierProvider.autoDispose<ClosetsPageNotifier, ClosetsPageState>((ref) {
  final repo = ref.watch(closetRepositoryProvider);
  return ClosetsPageNotifier(repo, ref);
});