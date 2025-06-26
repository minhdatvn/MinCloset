// lib/notifiers/city_selection_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/city_repository.dart';
import 'package:mincloset/states/city_selection_state.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';

class CitySelectionNotifier extends StateNotifier<CitySelectionState> {
  final CityRepository _cityRepo;
  final Ref _ref;
  Timer? _debounce;

  CitySelectionNotifier(this._cityRepo, this._ref)
      : super(const CitySelectionState()) {
    _loadInitialSettings();
  }

  void _loadInitialSettings() {
    // Đọc trạng thái từ profileProvider để biết cài đặt hiện tại là gì
    final profileState = _ref.read(profileProvider);
    state = state.copyWith(
      isLoading: false,
      selectedMode: profileState.cityMode,
      currentManualCityName: profileState.manualCity,
    );
  }

  void setMode(CityMode mode) {
    if (state.selectedMode == mode) return;
    state = state.copyWith(
      selectedMode: mode,
      // Xóa gợi ý cũ khi chuyển mode
      suggestions: [],
      clearSelectedSuggestion: true,
    );
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        state = state.copyWith(suggestions: []);
        return;
      }
      state = state.copyWith(isSearching: true);
      
      // <<< THAY ĐỔI CỐT LÕI NẰM Ở ĐÂY >>>
      // Gọi repository, kết quả trả về là một Either
      final result = await _cityRepo.searchCities(query);

      // Nếu notifier đã bị hủy trong lúc chờ kết quả, không làm gì cả
      if (!mounted) return;

      // Dùng .fold() để xử lý cả 2 trường hợp
      result.fold(
        // (l) => Left: Xử lý khi có lỗi
        (failure) {
          state = state.copyWith(
            isSearching: false,
            errorMessage: failure.message,
          );
        },
        // (r) => Right: Xử lý khi thành công
        (suggestions) {
          state = state.copyWith(
            isSearching: false,
            suggestions: suggestions,
          );
        },
      );
    });
  }

  void selectSuggestion(CitySuggestion suggestion) {
    state = state.copyWith(selectedSuggestion: suggestion, suggestions: []);
  }

  // Hàm quan trọng: Lưu lựa chọn của người dùng
  Future<bool> saveSelection() async {
    final profileNotifier = _ref.read(profileProvider.notifier);
    try {
      if (state.selectedMode == CityMode.manual) {
        // Nếu người dùng chưa chọn gợi ý nào thì không cho lưu
        if (state.selectedSuggestion == null) {
          state = state.copyWith(errorMessage: 'Please select a location from the suggestions');
          return false;
        }
        await profileNotifier.updateCityPreference(
          CityMode.manual,
          state.selectedSuggestion!,
        );
      } else { // Chế độ Tự động
        await profileNotifier.updateCityPreference(CityMode.auto, null);
      }
      return true;
    } catch (e) {
      logger.e('Failed to save location settings', error: e);
      // Cập nhật state với lỗi để UI có thể hiển thị
      state = state.copyWith(errorMessage: 'Failed to save location settings.');
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// Provider cho notifier mới
final citySelectionProvider = StateNotifierProvider.autoDispose<
    CitySelectionNotifier, CitySelectionState>((ref) {
  final cityRepo = ref.watch(cityRepositoryProvider);
  return CitySelectionNotifier(cityRepo, ref);
});