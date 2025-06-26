// lib/notifiers/outfits_hub_notifier.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/outfit_repository.dart';

// Kích thước của mỗi trang dữ liệu
const _pageSize = 20;

// Lớp State: Chứa toàn bộ dữ liệu cho màn hình OutfitsHub
class OutfitsHubState extends Equatable {
  final bool isLoading; // Đang tải lần đầu?
  final bool isLoadingMore; // Đang tải thêm?
  final bool hasMore; // Vẫn còn dữ liệu để tải?
  final List<Outfit> outfits;
  final String? error;

  const OutfitsHubState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.outfits = const [],
    this.error,
  });

  OutfitsHubState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    List<Outfit>? outfits,
    String? error,
    bool clearError = false,
  }) {
    return OutfitsHubState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      outfits: outfits ?? this.outfits,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadingMore, hasMore, outfits, error];
}

// Lớp Notifier: Chứa logic nghiệp vụ
class OutfitsHubNotifier extends StateNotifier<OutfitsHubState> {
  final OutfitRepository _outfitRepository;

  OutfitsHubNotifier(this._outfitRepository) : super(const OutfitsHubState()) {
    // Tải trang đầu tiên ngay khi notifier được tạo
    fetchInitialOutfits();
  }

  Future<void> fetchInitialOutfits() async {
    // Bắt đầu tải trang đầu tiên
    state = state.copyWith(isLoading: true, outfits: [], hasMore: true, clearError: true);
    try {
      final result = await _outfitRepository.getOutfits(limit: _pageSize, offset: 0);

      // Sử dụng fold để xử lý kết quả Either
      result.fold(
        // Trường hợp thất bại (Left)
        (failure) {
          state = state.copyWith(isLoading: false, error: failure.message); // Giả sử Failure có thuộc tính message
        },
        // Trường hợp thành công (Right)
        (newOutfits) {
          state = state.copyWith(
            isLoading: false,
            outfits: newOutfits,
            // Nếu số lượng trả về ít hơn kích thước trang, nghĩa là đã hết dữ liệu
            hasMore: newOutfits.length == _pageSize,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "An unexpected error occurred.");
    }
  }

  Future<void> fetchMoreOutfits() async {
    // Ngăn việc tải thêm nếu đang tải hoặc đã hết dữ liệu
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    
    // Tính toán offset cho trang tiếp theo
    final offset = state.outfits.length;

    try {
      final result = await _outfitRepository.getOutfits(limit: _pageSize, offset: offset);

      if (mounted) {
        result.fold(
          // Trường hợp thất bại (Left)
          (failure) {
            state = state.copyWith(isLoadingMore: false, error: failure.message); // Giả sử Failure có thuộc tính message
          },
          // Trường hợp thành công (Right)
          (newOutfits) {
            state = state.copyWith(
              isLoadingMore: false,
              // Thêm các bộ đồ mới vào danh sách hiện tại
              outfits: [...state.outfits, ...newOutfits],
              hasMore: newOutfits.length == _pageSize,
            );
          },
        );
      }
    } catch (e) {
       if (mounted) {
        state = state.copyWith(isLoadingMore: false, error: "An unexpected error occurred while loading more.");
      }
    }
  }
}

// Provider: Cung cấp Notifier cho UI
final outfitsHubProvider = StateNotifierProvider.autoDispose<OutfitsHubNotifier, OutfitsHubState>((ref) {
  final repo = ref.watch(outfitRepositoryProvider);
  return OutfitsHubNotifier(repo);
});