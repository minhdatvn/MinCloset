// lib/states/profile_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum CityMode { auto, manual }

@immutable
class ProfilePageState extends Equatable {
  final bool isLoading; // <<< THÊM TRƯỜNG NÀY
  final String? userName;
  final String? avatarPath;
  final CityMode cityMode;
  final String manualCity;
  final int totalItems;
  final int totalClosets;
  final int totalOutfits;
  final Map<String, int> colorDistribution;
  final Map<String, int> categoryDistribution;
  final String? errorMessage; // <<< THÊM TRƯỜNG NÀY ĐỂ BÁO LỖI

  const ProfilePageState({
    this.isLoading = true, // <<< Mặc định là đang tải khi mới khởi tạo
    this.userName,
    this.avatarPath,
    this.cityMode = CityMode.auto,
    this.manualCity = 'Da Nang',
    this.totalItems = 0,
    this.totalClosets = 0,
    this.totalOutfits = 0,
    this.colorDistribution = const {},
    this.categoryDistribution = const {},
    this.errorMessage,
  });

  ProfilePageState copyWith({
    bool? isLoading, // <<< THÊM VÀO ĐÂY
    String? userName,
    String? avatarPath,
    CityMode? cityMode,
    String? manualCity,
    int? totalItems,
    int? totalClosets,
    int? totalOutfits,
    Map<String, int>? colorDistribution,
    Map<String, int>? categoryDistribution,
    String? errorMessage,
  }) {
    return ProfilePageState(
      isLoading: isLoading ?? this.isLoading, // <<< THÊM VÀO ĐÂY
      userName: userName ?? this.userName,
      avatarPath: avatarPath ?? this.avatarPath,
      cityMode: cityMode ?? this.cityMode,
      manualCity: manualCity ?? this.manualCity,
      totalItems: totalItems ?? this.totalItems,
      totalClosets: totalClosets ?? this.totalClosets,
      totalOutfits: totalOutfits ?? this.totalOutfits,
      colorDistribution: colorDistribution ?? this.colorDistribution,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, // <<< THÊM VÀO ĐÂY
        userName,
        avatarPath,
        cityMode,
        manualCity,
        totalItems,
        totalClosets,
        totalOutfits,
        colorDistribution,
        categoryDistribution,
        errorMessage
      ];
}