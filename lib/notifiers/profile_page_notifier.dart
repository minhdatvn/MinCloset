// lib/notifiers/profile_page_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mincloset/models/city_suggestion.dart';
import 'package:mincloset/providers/event_providers.dart';
import 'package:mincloset/providers/repository_providers.dart';
import 'package:mincloset/repositories/closet_repository.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/settings_repository.dart';
import 'package:mincloset/services/number_formatting_service.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mincloset/routing/app_routes.dart';

final profileChangedTriggerProvider = StateProvider<int>((ref) => 0);

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
      
      // --- THAY ĐỔI: LẤY DỮ LIỆU TỪ REPOSITORY ---
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
      final currency = profileData[SettingsRepository.currencyKey] as String? ?? 'USD';
      final numberFormatString = profileData[SettingsRepository.numberFormatKey] as String? ?? 'dotDecimal';
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

  Future<bool> updateAvatar(BuildContext context) async {
    // Hàm helper để hiển thị menu lựa chọn
    Future<ImageSource?> showImageSourceMenu() async {
      return await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('From Album'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }

    // --- Bắt đầu luồng chính ---
    final imageSource = await showImageSourceMenu();
    if (imageSource == null) return false;

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: imageSource);
    if (pickedFile == null) return false;

    final imageBytes = await pickedFile.readAsBytes();

    if (!context.mounted) return false;
    final croppedBytes = await Navigator.of(context).pushNamed<Uint8List?>(
      AppRoutes.avatarCropper,
      arguments: imageBytes,
    );

    // Nếu người dùng có cắt và lưu ảnh
    if (croppedBytes != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/avatar.png';
        final imageFile = File(path);
        await imageFile.writeAsBytes(croppedBytes);

        // Chỉ lưu đường dẫn vào SharedPreferences
        await _settingsRepo.saveUserProfile({SettingsRepository.avatarPathKey: path});
        _ref.read(profileChangedTriggerProvider.notifier).state++;
        
        // Thay vào đó, trả về true để báo hiệu thành công
        return true; 
      } catch (e) {
        // Nếu có lỗi, trả về false
        return false;
      }
    }
    // Nếu người dùng không lưu, trả về false
    return false;
  }
  
    Future<void> updateProfileInfo(Map<String, dynamic> data) async {
    // Sửa lỗi: Luôn sử dụng các key đã được định nghĩa trong SettingsRepository
    await _settingsRepo.saveUserProfile({
      SettingsRepository.userNameKey: data['name'],
      SettingsRepository.genderKey: data['gender'],
      SettingsRepository.dobKey: (data['dob'] as DateTime?)?.toIso8601String(),
      SettingsRepository.heightKey: data['height'],
      SettingsRepository.weightKey: data['weight'],
      SettingsRepository.personalStylesKey: (data['personalStyles'] as Set<String>?)?.toList(),
      SettingsRepository.favoriteColorsKey: (data['favoriteColors'] as Set<String>?)?.toList(),
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
    // THAY ĐỔI: Sử dụng các hằng số từ SettingsRepository cho tất cả các key
    await _settingsRepo.saveUserProfile({
      SettingsRepository.cityModeKey: mode.name,
      SettingsRepository.manualCityKey: suggestion?.displayName,
      SettingsRepository.manualCityLatKey: suggestion?.lat,
      SettingsRepository.manualCityLonKey: suggestion?.lon,
    });
    
    // Cập nhật state của notifier như cũ
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
        // Tách chuỗi tên để lấy các thành phần
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