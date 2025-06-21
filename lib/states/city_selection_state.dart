// lib/states/city_selection_state.dart

import 'package:equatable/equatable.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/states/profile_page_state.dart';

class CitySelectionState extends Equatable {
  // Trạng thái chung
  final bool isLoading; // Dùng khi tải cài đặt ban đầu
  final bool isSearching; // Dùng khi đang gọi API tìm kiếm
  final String? errorMessage;

  // Trạng thái lựa chọn
  final CityMode selectedMode;
  final CitySuggestion? selectedSuggestion;

  // Trạng thái dữ liệu
  final List<CitySuggestion> suggestions; // Danh sách gợi ý từ API
  final String currentManualCityName; // Tên thành phố thủ công đang được lưu

  const CitySelectionState({
    this.isLoading = true,
    this.isSearching = false,
    this.errorMessage,
    this.selectedMode = CityMode.auto,
    this.selectedSuggestion,
    this.suggestions = const [],
    this.currentManualCityName = '',
  });

  CitySelectionState copyWith({
    bool? isLoading,
    bool? isSearching,
    String? errorMessage,
    CityMode? selectedMode,
    CitySuggestion? selectedSuggestion,
    bool clearSelectedSuggestion = false,
    List<CitySuggestion>? suggestions,
    String? currentManualCityName,
  }) {
    return CitySelectionState(
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMode: selectedMode ?? this.selectedMode,
      selectedSuggestion: clearSelectedSuggestion
          ? null
          : selectedSuggestion ?? this.selectedSuggestion,
      suggestions: suggestions ?? this.suggestions,
      currentManualCityName:
          currentManualCityName ?? this.currentManualCityName,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSearching,
        errorMessage,
        selectedMode,
        selectedSuggestion,
        suggestions,
        currentManualCityName,
      ];
}