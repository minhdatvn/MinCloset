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
      try {
        final results = await _cityRepo.searchCities(query);
        if (mounted) {
          state = state.copyWith(isSearching: false, suggestions: results);
        }
      } catch (e, s) {
        logger.e('Lỗi tìm kiếm thành phố', error: e, stackTrace: s);
        if (mounted) {
          state = state.copyWith(
              isSearching: false, errorMessage: 'Lỗi tìm kiếm');
        }
      }
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
          state = state.copyWith(errorMessage: 'Vui lòng chọn một thành phố từ danh sách gợi ý');
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
      logger.e('Lỗi khi lưu cài đặt thành phố', error: e);
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