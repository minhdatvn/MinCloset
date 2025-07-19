// lib/states/profile_page_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mincloset/services/number_formatting_service.dart';

enum CityMode { auto, manual }
enum HeightUnit { cm, ft }
enum WeightUnit { kg, lbs }
enum TempUnit { celsius, fahrenheit }


@immutable
class ProfilePageState extends Equatable {
  final bool isLoading;
  final String? userName;
  final String? avatarPath;
  final String? gender;
  final DateTime? dob;
  final int? height;
  final int? weight;
  final Set<String> personalStyles;
  final Set<String> favoriteColors;
  final CityMode cityMode;
  final String manualCity;
  final bool showWeatherImage;
  final bool showMascot;
  final int totalItems;
  final int totalClosets;
  final int totalOutfits;
  final Map<String, int> colorDistribution;
  final Map<String, int> categoryDistribution;
  final Map<String, int> seasonDistribution;
  final Map<String, int> occasionDistribution;
  final Map<String, int> materialDistribution;
  final Map<String, int> patternDistribution;
  final String? errorMessage;
  final String currency;
  final NumberFormatType numberFormat;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final TempUnit tempUnit;
  final bool showTooltips;

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
    this.showWeatherImage = true,
    this.showMascot = true,
    this.totalItems = 0,
    this.totalClosets = 0,
    this.totalOutfits = 0,
    this.colorDistribution = const {},
    this.categoryDistribution = const {},
    this.seasonDistribution = const {},
    this.occasionDistribution = const {},
    this.materialDistribution = const {},
    this.patternDistribution = const {},
    this.errorMessage,
    this.currency = 'USD',
    this.numberFormat = NumberFormatType.dotDecimal,
    this.heightUnit = HeightUnit.cm,
    this.weightUnit = WeightUnit.kg,
    this.tempUnit = TempUnit.celsius,
    this.showTooltips = true,
  });

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
    bool? showWeatherImage,
    bool? showMascot,
    int? totalItems,
    int? totalClosets,
    int? totalOutfits,
    Map<String, int>? colorDistribution,
    Map<String, int>? categoryDistribution,
    Map<String, int>? seasonDistribution,
    Map<String, int>? occasionDistribution,
    Map<String, int>? materialDistribution,
    Map<String, int>? patternDistribution, 
    String? errorMessage,
    String? currency,
    NumberFormatType? numberFormat,
    HeightUnit? heightUnit,
    WeightUnit? weightUnit,
    TempUnit? tempUnit,
    bool? showTooltips,
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
      showWeatherImage: showWeatherImage ?? this.showWeatherImage,
      showMascot: showMascot ?? this.showMascot,
      totalItems: totalItems ?? this.totalItems,
      totalClosets: totalClosets ?? this.totalClosets,
      totalOutfits: totalOutfits ?? this.totalOutfits,
      colorDistribution: colorDistribution ?? this.colorDistribution,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      seasonDistribution: seasonDistribution ?? this.seasonDistribution,
      occasionDistribution: occasionDistribution ?? this.occasionDistribution,
      materialDistribution: materialDistribution ?? this.materialDistribution,
      patternDistribution: patternDistribution ?? this.patternDistribution,
      errorMessage: errorMessage ?? this.errorMessage,
      currency: currency ?? this.currency,
      numberFormat: numberFormat ?? this.numberFormat,
      heightUnit: heightUnit ?? this.heightUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      tempUnit: tempUnit ?? this.tempUnit,
      showTooltips: showTooltips ?? this.showTooltips,
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
        showWeatherImage,
        showMascot,
        totalItems,
        totalClosets,
        totalOutfits,
        colorDistribution,
        categoryDistribution,
        seasonDistribution,
        occasionDistribution,
        materialDistribution, 
        patternDistribution, 
        errorMessage,
        currency,
        numberFormat,
        heightUnit,
        weightUnit,
        tempUnit,
        showTooltips,
      ];
}