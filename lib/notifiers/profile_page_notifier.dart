// lib/notifiers/profile_page_notifier.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/settings_repository.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

final profileChangedTriggerProvider = StateProvider<int>((ref) => 0);

class ProfilePageNotifier extends StateNotifier<ProfilePageState> {
  final Ref _ref;
  final ClosetRepository _closetRepo;
  final ClothingItemRepository _itemRepo;
  final OutfitRepository _outfitRepo;
  final SettingsRepository _settingsRepo;

  ProfilePageNotifier(
    this._ref,
    this._closetRepo,
    this._itemRepo,
    this._outfitRepo,
    this._settingsRepo,
  ) : super(const ProfilePageState()) {
    loadInitialData();

    _ref.listen<int>(itemChangedTriggerProvider, (previous, next) {
      if (previous != next) {
        loadInitialData();
      }
    });

    _ref.listen(profileChangedTriggerProvider, (previous, next) {
      if (previous != next) {
        loadInitialData();
      }
    });
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      logger.i('Loading profile data...');
      
      final profileData = await _settingsRepo.getUserProfile();
      final userName = profileData[SettingsRepository.userNameKey] as String? ?? 'MinCloset user';
      final avatarPath = profileData[SettingsRepository.avatarPathKey] as String?;
      final gender = profileData[SettingsRepository.genderKey] as String?;
      final dobString = profileData[SettingsRepository.dobKey] as String?;
      final dob = dobString != null ? DateTime.tryParse(dobString) : null;
      final height = profileData[SettingsRepository.heightKey] as int?;
      final weight = profileData[SettingsRepository.weightKey] as int?;
      final personalStyles = (profileData[SettingsRepository.personalStylesKey] as List<String>?)?.toSet() ?? {};
      final favoriteColors = (profileData[SettingsRepository.favoriteColorsKey] as List<String>?)?.toSet() ?? {};
      final cityModeString = profileData[SettingsRepository.cityModeKey] as String? ?? 'auto';
      final cityMode = CityMode.values.byName(cityModeString);
      final manualCity = profileData[SettingsRepository.manualCityKey] as String? ?? 'Ha Noi, VN';
      final showWeatherImage = profileData[SettingsRepository.showWeatherImageKey] as bool? ?? true;
      final showMascot = profileData[SettingsRepository.showMascotKey] as bool? ?? true;
      final currency = profileData[SettingsRepository.currencyKey] as String? ?? 'USD';
      final numberFormatString = profileData[SettingsRepository.numberFormatKey] as String? ?? 'dotDecimal';
      final numberFormat = NumberFormatType.values.firstWhere(
        (e) => e.name == numberFormatString,
        orElse: () => NumberFormatType.dotDecimal,
      );
      final heightUnitString = profileData[SettingsRepository.heightUnitKey] as String? ?? 'cm';
      final heightUnit = HeightUnit.values.byName(heightUnitString);
      final weightUnitString = profileData[SettingsRepository.weightUnitKey] as String? ?? 'kg';
      final weightUnit = WeightUnit.values.byName(weightUnitString);
      final tempUnitString = profileData[SettingsRepository.tempUnitKey] as String? ?? 'celsius';
      final tempUnit = TempUnit.values.byName(tempUnitString);
      
      logger.i('3. Successfully read settings from repository.');

      final allItemsResult = await _itemRepo.getAllItems();
      allItemsResult.fold(
        (failure) {
          logger.e("Failed to load items", error: failure.message);
          state =
              state.copyWith(isLoading: false, errorMessage: failure.message);
        },
        (allItems) async {
          logger.i('4. Successfully loaded all items from database.');
          final allClosetsResult = await _closetRepo.getClosets();
          allClosetsResult.fold(
            (failure) {
              logger.e("Failed to load closets", error: failure.message);
              state = state.copyWith(
                  isLoading: false, errorMessage: failure.message);
            },
            (allClosets) async {
              logger.i('5. Successfully loaded all closets from database.');
              final allOutfitsResult = await _outfitRepo.getOutfits();
              allOutfitsResult.fold(
                (failure) {
                  logger.e("Failed to load outfits", error: failure.message);
                  state = state.copyWith(
                      isLoading: false, errorMessage: failure.message);
                },
                (allOutfits) {
                  logger.i(
                      '6. Successfully loaded all outfits from database.');

                  final colorDist = <String, int>{};
                  final categoryDist = <String, int>{};
                  final seasonDist = <String, int>{};
                  final occasionDist = <String, int>{};
                  final materialDist = <String, int>{}; 
                  final patternDist = <String, int>{}; 

                  for (final item in allItems) {
                    final colors = item.color
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty);
                    for (final color in colors) {
                      colorDist[color] = (colorDist[color] ?? 0) + 1;
                    }
                    final mainCategory =
                        item.category.split('>').first.trim();
                    if (mainCategory.isNotEmpty) {
                      categoryDist[mainCategory] =
                          (categoryDist[mainCategory] ?? 0) + 1;
                    }
                    if (item.season != null && item.season!.isNotEmpty) {
                      final seasons =
                          item.season!.split(',').map((e) => e.trim());
                      for (final season in seasons) {
                        seasonDist[season] = (seasonDist[season] ?? 0) + 1;
                      }
                    }
                    if (item.occasion != null &&
                        item.occasion!.isNotEmpty) {
                      final occasions =
                          item.occasion!.split(',').map((e) => e.trim());
                      for (final occasion in occasions) {
                        occasionDist[occasion] =
                            (occasionDist[occasion] ?? 0) + 1;
                      }
                    }
                    if (item.material != null && item.material!.isNotEmpty) {
                      final materials =
                          item.material!.split(',').map((e) => e.trim());
                      for (final material in materials) {
                        materialDist[material] =
                            (materialDist[material] ?? 0) + 1;
                      }
                    }
                    if (item.pattern != null && item.pattern!.isNotEmpty) {
                      final patterns =
                          item.pattern!.split(',').map((e) => e.trim());
                      for (final pattern in patterns) {
                        patternDist[pattern] =
                            (patternDist[pattern] ?? 0) + 1;
                      }
                    }
                  }
                  logger.i('7. Statistics calculated successfully.');

                  state = state.copyWith(
                    isLoading: false,
                    userName: userName,
                    avatarPath: avatarPath,
                    gender: gender,
                    dob: dob,
                    height: height,
                    weight: weight,
                    personalStyles: personalStyles,
                    favoriteColors: favoriteColors,
                    cityMode: cityMode,
                    manualCity: manualCity,
                    showWeatherImage: showWeatherImage,
                    showMascot: showMascot,
                    totalItems: allItems.length,
                    totalClosets: allClosets.length,
                    totalOutfits: allOutfits.length,
                    colorDistribution: colorDist,
                    categoryDistribution: categoryDist,
                    seasonDistribution: seasonDist,
                    occasionDistribution: occasionDist,
                    materialDistribution: materialDist, 
                    patternDistribution: patternDist,
                    currency: currency,
                    numberFormat: numberFormat,
                    heightUnit: heightUnit,
                    weightUnit: weightUnit,
                    tempUnit: tempUnit,
                  );
                  logger.i(
                      '8. State updated successfully! Profile page loading complete.');
                },
              );
            },
          );
        },
      );
    } catch (e, s) {
      logger.e("An unexpected error occurred in loadInitialData.",
          error: e, stackTrace: s);
      state = state.copyWith(
        isLoading: false,
        errorMessage: "An unexpected error occurred. Please try again.",
      );
    }
  }

  Future<void> updateShowWeatherImage(bool newValue) async {
    await _settingsRepo.saveUserProfile({'showWeatherImage': newValue});
    state = state.copyWith(showWeatherImage: newValue);
  }

  Future<void> updateShowMascot(bool newValue) async {
    await _settingsRepo.saveUserProfile({SettingsRepository.showMascotKey: newValue});
    state = state.copyWith(showMascot: newValue);
  }

  Future<bool> saveAvatar(Uint8List croppedBytes) async { // <<< PHƯƠNG THỨC MỚI ĐỂ LƯU AVATAR >>>
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/avatar.png';
      final imageFile = File(path);
      await imageFile.writeAsBytes(croppedBytes);

      // Lưu đường dẫn vào SharedPreferences
      await _settingsRepo.saveUserProfile({SettingsRepository.avatarPathKey: path});
      _ref.read(profileChangedTriggerProvider.notifier).state++;
      
      return true; // Trả về true để báo hiệu thành công
    } catch (e) {
      // Nếu có lỗi, trả về false
      return false;
    }
  }
  
  Future<void> updateProfileInfo(Map<String, dynamic> data) async {
    await _settingsRepo.saveUserProfile({
      SettingsRepository.userNameKey: data['name'],
      SettingsRepository.genderKey: data['gender'],
      SettingsRepository.dobKey: (data['dob'] as DateTime?)?.toIso8601String(),
      SettingsRepository.heightKey: data['height'],
      SettingsRepository.weightKey: data['weight'],
      SettingsRepository.personalStylesKey: (data['personalStyles'] as Set<String>?)?.toList(),
      SettingsRepository.favoriteColorsKey: (data['favoriteColors'] as Set<String>?)?.toList(),
    });

    state = state.copyWith(
      userName: data['name'],
      gender: data['gender'],
      dob: data['dob'],
      height: data['height'],
      weight: data['weight'],
      personalStyles: data['personalStyles'],
      favoriteColors: data['favoriteColors'],
    );
  }

  Future<void> updateCityPreference(
      CityMode mode, CitySuggestion? suggestion) async {
    await _settingsRepo.saveUserProfile({
      SettingsRepository.cityModeKey: mode.name,
      SettingsRepository.manualCityKey: suggestion?.displayName,
      SettingsRepository.manualCityLatKey: suggestion?.lat,
      SettingsRepository.manualCityLonKey: suggestion?.lon,
    });
    
    state = state.copyWith(
        cityMode: mode,
        manualCity: suggestion != null ? suggestion.displayName : state.manualCity,
    );
  }

  Future<Map<String, dynamic>?> getManualCityDetails() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final lat = prefs.getDouble(SettingsRepository.manualCityLatKey);
    final lon = prefs.getDouble(SettingsRepository.manualCityLonKey);
    final name = prefs.getString('manualCity');
    
    if (name != null && lat != null && lon != null) {
        final parts = name.split(', ');
        return {
            'name': parts.first,
            'country': parts.last,
            'state': parts.length > 2 ? parts[1] : null,
            'lat': lat,
            'lon': lon,
        };
    }
    return null;
  }

  Future<void> updateFormattingSettings({String? currency, NumberFormatType? format}) async {
    final Map<String, dynamic> dataToSave = {};
    if (currency != null) {
      dataToSave['currency'] = currency;
    }
    if (format != null) {
      dataToSave['numberFormat'] = format.name;
    }

    await _settingsRepo.saveUserProfile(dataToSave);
    
    state = state.copyWith(
      currency: currency ?? state.currency,
      numberFormat: format ?? state.numberFormat,
    );
  }

  Future<void> updateMeasurementUnits({
    HeightUnit? height,
    WeightUnit? weight,
    TempUnit? temp,
  }) async {
    final Map<String, dynamic> dataToSave = {};
    if (height != null) {
      dataToSave[SettingsRepository.heightUnitKey] = height.name;
    }
    if (weight != null) {
      dataToSave[SettingsRepository.weightUnitKey] = weight.name;
    }
    if (temp != null) {
      dataToSave[SettingsRepository.tempUnitKey] = temp.name;
    }

    if (dataToSave.isNotEmpty) {
      await _settingsRepo.saveUserProfile(dataToSave);
    }
    
    state = state.copyWith(
      heightUnit: height ?? state.heightUnit,
      weightUnit: weight ?? state.weightUnit,
      tempUnit: temp ?? state.tempUnit,
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfilePageNotifier, ProfilePageState>((ref) {
  final closetRepo = ref.watch(closetRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider); 
  
  return ProfilePageNotifier(ref, closetRepo, itemRepo, outfitRepo, settingsRepo);
});