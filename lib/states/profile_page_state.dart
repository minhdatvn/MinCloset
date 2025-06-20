// lib/states/profile_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum CityMode { auto, manual }

@immutable
class ProfilePageState extends Equatable {
  final bool isLoading;
  final String? userName;
  final String? avatarPath;
  final CityMode cityMode;
  final String manualCity;
  final int totalItems;
  final int totalClosets;
  final int totalOutfits;
  final Map<String, int> colorDistribution;
  final Map<String, int> categoryDistribution;
  // <<< THÊM 2 TRƯỜNG MỚI >>>
  final Map<String, int> seasonDistribution;
  final Map<String, int> occasionDistribution;
  final String? errorMessage;

  const ProfilePageState({
    this.isLoading = true,
    this.userName,
    this.avatarPath,
    this.cityMode = CityMode.auto,
    this.manualCity = 'Da Nang',
    this.totalItems = 0,
    this.totalClosets = 0,
    this.totalOutfits = 0,
    this.colorDistribution = const {},
    this.categoryDistribution = const {},
    // <<< KHỞI TẠO GIÁ TRỊ MẶC ĐỊNH >>>
    this.seasonDistribution = const {},
    this.occasionDistribution = const {},
    this.errorMessage,
  });

  ProfilePageState copyWith({
    bool? isLoading,
    String? userName,
    String? avatarPath,
    CityMode? cityMode,
    String? manualCity,
    int? totalItems,
    int? totalClosets,
    int? totalOutfits,
    Map<String, int>? colorDistribution,
    Map<String, int>? categoryDistribution,
    // <<< THÊM VÀO HÀM COPYWITH >>>
    Map<String, int>? seasonDistribution,
    Map<String, int>? occasionDistribution,
    String? errorMessage,
  }) {
    return ProfilePageState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      avatarPath: avatarPath ?? this.avatarPath,
      cityMode: cityMode ?? this.cityMode,
      manualCity: manualCity ?? this.manualCity,
      totalItems: totalItems ?? this.totalItems,
      totalClosets: totalClosets ?? this.totalClosets,
      totalOutfits: totalOutfits ?? this.totalOutfits,
      colorDistribution: colorDistribution ?? this.colorDistribution,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      // <<< CẬP NHẬT Ở ĐÂY >>>
      seasonDistribution: seasonDistribution ?? this.seasonDistribution,
      occasionDistribution: occasionDistribution ?? this.occasionDistribution,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        userName,
        avatarPath,
        cityMode,
        manualCity,
        totalItems,
        totalClosets,
        totalOutfits,
        colorDistribution,
        categoryDistribution,
        // <<< THÊM VÀO PROPS >>>
        seasonDistribution,
        occasionDistribution,
        errorMessage
      ];
}