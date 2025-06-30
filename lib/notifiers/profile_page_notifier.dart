// lib/notifiers/profile_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/notifiers/home_page_notifier.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePageNotifier extends StateNotifier<ProfilePageState> {
  final Ref _ref;
  final ClosetRepository _closetRepo;
  final ClothingItemRepository _itemRepo;
  final OutfitRepository _outfitRepo;

  ProfilePageNotifier(
    this._ref,
    this._closetRepo,
    this._itemRepo,
    this._outfitRepo,
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
      final prefs = await SharedPreferences.getInstance();
      logger.i('1, 2. Repositories and SharedPreferences initialized.');

      final userName = prefs.getString('user_name') ?? 'MinCloset user';
      final avatarPath = prefs.getString('user_avatar_path');
      final gender = prefs.getString('user_gender');
      final dobString = prefs.getString('user_dob');
      final dob = dobString != null ? DateTime.tryParse(dobString) : null;
      final height = prefs.getInt('user_height');
      final weight = prefs.getInt('user_weight');
      final personalStyles = prefs.getStringList('user_styles')?.toSet() ?? {};
      final favoriteColors =
          prefs.getStringList('user_favorite_colors')?.toSet() ?? {};
      final cityModeString = prefs.getString('city_mode') ?? 'auto';
      final cityMode = CityMode.values.byName(cityModeString);
      final manualCity = prefs.getString('manual_city_name') ?? 'Ha Noi, VN';
      // <<< THÊM MỚI: Đọc giá trị cài đặt ảnh nền thời tiết >>>
      final showWeatherImage = prefs.getBool('show_weather_image') ?? true;
      logger.i('3. Successfully read SharedPreferences.');

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

  // <<< BẮT ĐẦU: THÊM HÀM MỚI Ở ĐÂY >>>
  Future<void> updateShowWeatherImage(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_weather_image', newValue);
    state = state.copyWith(showWeatherImage: newValue);
  }
  // <<< KẾT THÚC: THÊM HÀM MỚI Ở ĐÂY >>>

  Future<void> updateAvatar() async {
    // ... (logic không đổi)
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final path = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path', path);
      state = state.copyWith(avatarPath: path);
    }
  }

  Future<void> updateProfileInfo(Map<String, dynamic> data) async {
    // ... (logic không đổi)
    final prefs = await SharedPreferences.getInstance();

    final name = data['name'] as String?;
    final gender = data['gender'] as String?;
    final dob = data['dob'] as DateTime?;
    final height = data['height'] as int?;
    final weight = data['weight'] as int?;
    final personalStyles = data['personalStyles'] as Set<String>?;
    final favoriteColors = data['favoriteColors'] as Set<String>?;

    await _saveString(prefs, 'user_name', name);
    await _saveString(prefs, 'user_gender', gender);
    if (dob != null) {
      await prefs.setString('user_dob', dob.toIso8601String());
    } else {
      await prefs.remove('user_dob');
    }
    await _saveInt(prefs, 'user_height', height);
    await _saveInt(prefs, 'user_weight', weight);
    if (personalStyles != null) {
      await prefs.setStringList('user_styles', personalStyles.toList());
    } else {
      await prefs.remove('user_styles');
    }
    if (favoriteColors != null) {
      await prefs.setStringList(
          'user_favorite_colors', favoriteColors.toList());
    } else {
      await prefs.remove('user_favorite_colors');
    }

    state = state.copyWith(
      userName: name,
      gender: gender,
      dob: dob,
      height: height,
      weight: weight,
      personalStyles: personalStyles,
      favoriteColors: favoriteColors,
    );
  }

  Future<void> updateCityPreference(
      CityMode mode, CitySuggestion? suggestion) async {
    // ... (logic không đổi)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_mode', mode.name);

    if (mode == CityMode.manual && suggestion != null) {
      await prefs.setString('manual_city_name', suggestion.displayName);
      await prefs.setDouble('manual_city_lat', suggestion.lat);
      await prefs.setDouble('manual_city_lon', suggestion.lon);
      state =
          state.copyWith(cityMode: mode, manualCity: suggestion.displayName);
    } else {
      await prefs.remove('manual_city_name');
      await prefs.remove('manual_city_lat');
      await prefs.remove('manual_city_lon');
      state = state.copyWith(cityMode: mode);
    }

    _ref.read(homeProvider.notifier).getNewSuggestion();
  }

  Future<void> _saveString(
      SharedPreferences prefs, String key, String? value) async {
    // ... (logic không đổi)
    if (value != null && value.isNotEmpty) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  Future<void> _saveInt(SharedPreferences prefs, String key, int? value) async {
    // ... (logic không đổi)
    if (value != null) {
      await prefs.setInt(key, value);
    } else {
      await prefs.remove(key);
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfilePageNotifier, ProfilePageState>((ref) {
  final closetRepo = ref.watch(closetRepositoryProvider);
  final itemRepo = ref.watch(clothingItemRepositoryProvider);
  final outfitRepo = ref.watch(outfitRepositoryProvider);
  return ProfilePageNotifier(ref, closetRepo, itemRepo, outfitRepo);
});