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

  Future<bool> addCloset(String name) async {
    if (name.trim().isEmpty) {
      return false;
    }
    state = const ClosetsPageState(isLoading: true);
    try {
      final newCloset = Closet(id: const Uuid().v4(), name: name.trim());
      await _closetRepo.insertCloset(newCloset);
      
      // Vô hiệu hóa provider `closetsProvider` để nó tự động tải lại danh sách mới
      _ref.invalidate(closetsProvider);
      state = const ClosetsPageState(isLoading: false);
      return true;
    } catch (e) {
      state = ClosetsPageState(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// Tạo provider cho notifier mới
final closetsPageProvider = StateNotifierProvider.autoDispose<ClosetsPageNotifier, ClosetsPageState>((ref) {
  final repo = ref.watch(closetRepositoryProvider);
  return ClosetsPageNotifier(repo, ref);
});