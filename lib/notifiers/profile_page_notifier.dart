// lib/notifiers/profile_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/settings_repository.dart'; // <-- ĐÃ THÊM
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';

class ProfilePageNotifier extends StateNotifier<ProfilePageState> {
  final Ref _ref;
  final ClosetRepository _closetRepo;
  final ClothingItemRepository _itemRepo;
  final OutfitRepository _outfitRepo;
  final SettingsRepository _settingsRepo; // <-- ĐÃ THÊM

  ProfilePageNotifier(
    this._ref,
    this._closetRepo,
    this._itemRepo,
    this._outfitRepo,
    this._settingsRepo, // <-- ĐÃ THÊM
  ) : super(const ProfilePageState()) {
    loadInitialData();

    _ref.listen<int>(itemChangedTriggerProvider, (previous, next) {
      if (previous != next) {
        loadInitialData();
      }
    });
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      logger.i('Loading profile data...');
      
      // --- THAY ĐỔI: LẤY DỮ LIỆU TỪ REPOSITORY ---
      final profileData = await _settingsRepo.getUserProfile();
      final userName = profileData['name'] as String? ?? 'MinCloset user';
      final avatarPath = profileData['avatarPath'] as String?;
      final gender = profileData['gender'] as String?;
      final dobString = profileData['dob'] as String?;
      final dob = dobString != null ? DateTime.tryParse(dobString) : null;
      final height = profileData['height'] as int?;
      final weight = profileData['weight'] as int?;
      final personalStyles = (profileData['personalStyles'] as List<String>?)?.toSet() ?? {};
      final favoriteColors = (profileData['favoriteColors'] as List<String>?)?.toSet() ?? {};
      final cityModeString = profileData['cityMode'] as String? ?? 'auto';
      final cityMode = CityMode.values.byName(cityModeString);
      final manualCity = profileData['manualCity'] as String? ?? 'Ha Noi, VN';
      final showWeatherImage = profileData['showWeatherImage'] as bool? ?? true;
      final currency = profileData['currency'] as String? ?? 'USD';
      final numberFormatString = profileData['numberFormat'] as String? ?? 'dotDecimal';
      final numberFormat = NumberFormatType.values.firstWhere(
        (e) => e.name == numberFormatString,
        orElse: () => NumberFormatType.dotDecimal,
      );
      
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
    // THAY ĐỔI: Sử dụng repository để lưu
    await _settingsRepo.saveUserProfile({'showWeatherImage': newValue});
    state = state.copyWith(showWeatherImage: newValue);
  }

  Future<void> updateAvatar() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final path = pickedFile.path;
      // THAY ĐỔI: Sử dụng repository để lưu
      await _settingsRepo.saveUserProfile({'avatarPath': path});
      state = state.copyWith(avatarPath: path);
    }
  }

  Future<void> updateProfileInfo(Map<String, dynamic> data) async {
    // THAY ĐỔI: Toàn bộ logic lưu được chuyển vào repository
    await _settingsRepo.saveUserProfile({
      'name': data['name'],
      'gender': data['gender'],
      'dob': (data['dob'] as DateTime?)?.toIso8601String(),
      'height': data['height'],
      'weight': data['weight'],
      'personalStyles': (data['personalStyles'] as Set<String>?)?.toList(),
      'favoriteColors': (data['favoriteColors'] as Set<String>?)?.toList(),
    });

    // Cập nhật state như cũ
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
    // THAY ĐỔI: Sử dụng repository để lưu
    await _settingsRepo.saveUserProfile({
      'cityMode': mode.name,
      'manualCity': suggestion?.displayName,
      'manualCityLat': suggestion?.lat,
      'manualCityLon': suggestion?.lon,
    });
    
    state = state.copyWith(
        cityMode: mode,
        manualCity: suggestion != null ? suggestion.displayName : state.manualCity,
    );
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
    
    // Cập nhật state của notifier
    state = state.copyWith(
      currency: currency ?? state.currency,
      numberFormat: format ?? state.numberFormat,
    );
  }
}

// THAY ĐỔI: Cập nhật provider
final profileProvider =
    StateNotifierProvider<ProfilePageNotifier, ProfilePageState>((ref) {
  final closetRepo = ref.watch(closetRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider); // Lấy repo mới
  
  return ProfilePageNotifier(ref, closetRepo, itemRepo, outfitRepo, settingsRepo); // Truyền vào
});