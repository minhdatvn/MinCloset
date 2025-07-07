// lib/notifiers/city_selection_notifier.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/notifiers/profile_page_notifier.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/city_repository.dart';
import 'package:mincloset/states/city_selection_state.dart';
import 'package:mincloset/states/profile_page_state.dart';

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

  Future<void> setManualMode() async {
    if (state.selectedMode == CityMode.manual) return;

    final profileNotifier = _ref.read(profileProvider.notifier);
    var suggestionData = await profileNotifier.getManualCityDetails();

    // --- BẮT ĐẦU NÂNG CẤP LOGIC ---
    // Nếu không tìm thấy dữ liệu chi tiết (lat/lon)
    if (suggestionData == null) {
      // Nhưng vẫn có tên thành phố cũ
      if (state.currentManualCityName.isNotEmpty) {
        // Thực hiện một cuộc gọi API để tìm kiếm thông tin cho tên thành phố này
        final searchResult = await _cityRepo.searchCities(state.currentManualCityName);
        
        // Dùng fold để xử lý kết quả
        await searchResult.fold(
          (failure) { /* Lỗi: không làm gì cả, chỉ chuyển giao diện */ },
          (suggestions) async {
            // Nếu tìm thấy kết quả
            if (suggestions.isNotEmpty) {
              // Lấy kết quả đầu tiên và lưu lại
              final hydratedSuggestion = suggestions.first;
              await selectManualCity(hydratedSuggestion);
            }
          },
        );
      }
      // Nếu không có cả tên thành phố cũ, chỉ chuyển giao diện
      state = state.copyWith(selectedMode: CityMode.manual);
      return; // Kết thúc hàm tại đây
    }

    // Logic cũ chỉ chạy khi suggestionData đã tồn tại ngay từ đầu
    final lastSuggestion = CitySuggestion(
      name: suggestionData['name'] ?? 'Unknown',
      country: suggestionData['country'] ?? '',
      lat: suggestionData['lat'] ?? 0.0,
      lon: suggestionData['lon'] ?? 0.0,
      state: suggestionData['state'],
    );

    state = state.copyWith(
      selectedMode: CityMode.manual,
      selectedSuggestion: lastSuggestion,
      currentManualCityName: lastSuggestion.displayName,
    );
    await profileNotifier.updateCityPreference(CityMode.manual, lastSuggestion);
  }

  Future<void> selectAutoDetect() async {
    // Cập nhật UI ngay lập tức
    state = state.copyWith(
      selectedMode: CityMode.auto,
      suggestions: [],
      clearSelectedSuggestion: true,
    );
    // Gọi đến profile notifier để lưu cài đặt trong nền
    await _ref.read(profileProvider.notifier).updateCityPreference(CityMode.auto, null);
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

  Future<void> selectManualCity(CitySuggestion suggestion) async {
    // Cập nhật UI ngay lập tức
    state = state.copyWith(
      selectedMode: CityMode.manual,
      selectedSuggestion: suggestion,
      suggestions: [], // Xóa danh sách gợi ý
      currentManualCityName: suggestion.displayName, // Cập nhật tên thành phố hiển thị
    );
    // Gọi đến profile notifier để lưu cài đặt trong nền
    await _ref.read(profileProvider.notifier).updateCityPreference(CityMode.manual, suggestion);
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