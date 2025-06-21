// lib/states/profile_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum CityMode { auto, manual }

@immutable
class ProfilePageState extends Equatable {
  final bool isLoading;
  final String? userName;
  final String? avatarPath;
  final String? gender;
  final DateTime? dob; // <<< THAY age (int) BẰNG dob (DateTime) >>>
  final int? height;
  final int? weight;
  final Set<String> personalStyles; // <<< THÊM MỚI >>>
  final Set<String> favoriteColors; // <<< THÊM MỚI >>>
  final CityMode cityMode;
  final String manualCity;
  final int totalItems;
  final int totalClosets;
  final int totalOutfits;
  final Map<String, int> colorDistribution;
  final Map<String, int> categoryDistribution;
  final Map<String, int> seasonDistribution;
  final Map<String, int> occasionDistribution;
  final String? errorMessage;

  const ProfilePageState({
    this.isLoading = true,
    this.userName,
    this.avatarPath,
    this.gender,
    this.dob,
    this.height,
    this.weight,
    this.personalStyles = const {},
    this.favoriteColors = const {},
    this.cityMode = CityMode.auto,
    this.manualCity = 'Da Nang',
    this.totalItems = 0,
    this.totalClosets = 0,
    this.totalOutfits = 0,
    this.colorDistribution = const {},
    this.categoryDistribution = const {},
    this.seasonDistribution = const {},
    this.occasionDistribution = const {},
    this.errorMessage,
  });

  // <<< THÊM GETTER TÍNH TUỔI TỪ NGÀY SINH >>>
  int? get age {
    if (dob == null) return null;
    final today = DateTime.now();
    int age = today.year - dob!.year;
    if (today.month < dob!.month ||
        (today.month == dob!.month && today.day < dob!.day)) {
      age--;
    }
    return age;
  }

  ProfilePageState copyWith({
    bool? isLoading,
    String? userName,
    String? avatarPath,
    String? gender,
    DateTime? dob,
    int? height,
    int? weight,
    Set<String>? personalStyles,
    Set<String>? favoriteColors,
    CityMode? cityMode,
    String? manualCity,
    int? totalItems,
    int? totalClosets,
    int? totalOutfits,
    Map<String, int>? colorDistribution,
    Map<String, int>? categoryDistribution,
    Map<String, int>? seasonDistribution,
    Map<String, int>? occasionDistribution,
    String? errorMessage,
  }) {
    return ProfilePageState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      avatarPath: avatarPath ?? this.avatarPath,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      personalStyles: personalStyles ?? this.personalStyles,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      cityMode: cityMode ?? this.cityMode,
      manualCity: manualCity ?? this.manualCity,
      totalItems: totalItems ?? this.totalItems,
      totalClosets: totalClosets ?? this.totalClosets,
      totalOutfits: totalOutfits ?? this.totalOutfits,
      colorDistribution: colorDistribution ?? this.colorDistribution,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
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
        gender,
        dob,
        height,
        weight,
        personalStyles,
        favoriteColors,
        cityMode,
        manualCity,
        totalItems,
        totalClosets,
        totalOutfits,
        colorDistribution,
        categoryDistribution,
        seasonDistribution,
        occasionDistribution,
        errorMessage
      ];
}