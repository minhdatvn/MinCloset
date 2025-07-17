// lib/domain/use_cases/get_outfit_suggestion_use_case.dart
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mincloset/constants/prompt_strings.dart';
import 'package:mincloset/domain/failures/failures.dart';
import 'package:mincloset/domain/models/suggestion_result.dart';
import 'package:mincloset/models/clothing_item.dart';
import 'package:mincloset/models/outfit.dart';
import 'package:mincloset/repositories/clothing_item_repository.dart';
import 'package:mincloset/repositories/outfit_repository.dart';
import 'package:mincloset/repositories/settings_repository.dart';
import 'package:mincloset/repositories/suggestion_repository.dart';
import 'package:mincloset/repositories/weather_repository.dart';
import 'package:mincloset/states/profile_page_state.dart';
import 'package:mincloset/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetOutfitSuggestionUseCase {
  final ClothingItemRepository _clothingItemRepo;
  final WeatherRepository _weatherRepo;
  final SuggestionRepository _suggestionRepo;
  final OutfitRepository _outfitRepo;
  final SettingsRepository _settingsRepo;
  final SharedPreferences _prefs;

  GetOutfitSuggestionUseCase(
    this._clothingItemRepo,
    this._weatherRepo,
    this._suggestionRepo,
    this._outfitRepo,
    this._settingsRepo,
    this._prefs,
  );

  // Sửa lỗi `asyncMap` bằng cách await và fold một cách thủ công.
  // Đây là cách tiếp cận đơn giản và rõ ràng nhất.
  Future<Either<Failure, Map<String, dynamic>>> getWeatherForSuggestion() async {

    // <<< BẮT ĐẦU VÙNG GIẢ LẬP DỮ LIỆU - KHÔNG XÓA >>>
    // CHỈ CẦN THAY ĐỔI GIÁ TRỊ 'icon' DƯỚI ĐÂY ĐỂ TEST
    // '01d' -> Nắng, '04d' -> Mây, '10d' -> Mưa, '11d' -> Bão, '13d' -> Tuyết, '50d' -> Sương mù
    // const String debugWeatherIcon = '01d'; // <--- THAY ĐỔI ICON Ở ĐÂY ĐỂ TEST
    // final Map<String, dynamic> mockWeatherData = {
    //   "weather": [
    //     {
    //       "icon": debugWeatherIcon, 
    //       "description": "Debug Weather"
    //     }
    //   ],
    //   "main": {"temp": 25.0},
    //   "name": "Test Location"
    // };
    // // Lệnh return này sẽ trả về dữ liệu giả và bỏ qua toàn bộ logic gọi API thật
    // return Right(mockWeatherData); 
    // <<< KẾT THÚC VÙNG GIẢ LẬP DỮ LIỆU >>>

    final settings = await _settingsRepo.getUserProfile();
    final cityModeString = settings[SettingsRepository.cityModeKey] as String? ?? 'auto';
    final cityMode = CityMode.values.byName(cityModeString);

    if (cityMode == CityMode.manual) {
      final lat = settings[SettingsRepository.manualCityLatKey] as double?;
      final lon = settings[SettingsRepository.manualCityLonKey] as double?;

      if (lat != null && lon != null) {
          logger.i('Get weather by saved coordinates: ($lat, $lon)');
          final weatherData = await _weatherRepo.getWeatherByCoords(lat, lon);
          
          return weatherData.map((data) {
              data['name'] = settings['manualCity'] ?? data['name'] ?? 'Unknown Location';
              return data;
          });
      } else {
          // --- BẮT ĐẦU SỬA ĐỔI ---
          logger.w('Manual location data is missing. User needs to re-select a city.');
          // Trả về một Failure rõ ràng thay vì lấy thời tiết mặc định.
          return const Left(GenericFailure('GetOutfitSuggestion_error_manualLocationMissing'));
          // --- KẾT THÚC SỬA ĐỔI ---
      }
    } else { // Chế độ Auto-detect không thay đổi
      try {
        logger.i('Getting weather by auto-detecting location…');
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return const Left(GenericFailure('GetOutfitSuggestion_error_locationServicesDisabled'));
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return const Left(GenericFailure('GetOutfitSuggestion_error_locationPermissionDenied'));
        }

        late LocationSettings locationSettings;

        if (Platform.isAndroid) {
          locationSettings = AndroidSettings(
            accuracy: LocationAccuracy.high,
            forceLocationManager: true,
          );
        } else if (Platform.isIOS || Platform.isMacOS) {
          locationSettings = AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.other,
            pauseLocationUpdatesAutomatically: true,
          );
        } else {
            locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high,
          );
        }
        
        final position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

        final weatherEither = await _weatherRepo.getWeatherByCoords(position.latitude, position.longitude);

        return weatherEither.fold(
          (failure) => Left(failure),
          (weatherData) async {
            final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
            weatherData['name'] = placemarks.first.administrativeArea ?? placemarks.first.locality ?? 'Current Location';
            return Right(weatherData);
          },
        );
      } catch (e, s) {
        logger.e("Failed to get auto location or weather.", error: e, stackTrace: s);
        Sentry.captureException(e, stackTrace: s);
        // Thay vì lấy thời tiết mặc định, trả về một Failure rõ ràng
        return const Left(GenericFailure('GetOutfitSuggestion_error_locationUndetermined'));
      }
    }
  }
  
  // Sửa lỗi `tryCatch` và kiểu trả về bằng cách dùng TaskEither đúng cách
  Future<Either<Failure, Map<String, dynamic>>> execute({
    String? purpose,
    required bool isWeatherReliable, // Thêm tham số mới
  }) {
    TaskEither<Failure, Map<String, dynamic>> task;

    if (isWeatherReliable) {
      // Nếu cần thời tiết, bắt đầu bằng việc lấy thời tiết
      task = TaskEither(getWeatherForSuggestion)
        .flatMap((weatherData) => _getItemsAndOutfits(weatherData))
        .flatMap((data) => _getSuggestionFromAI(data));
    } else {
      // Nếu không cần thời tiết, bắt đầu bằng việc lấy item/outfit
      // và truyền weatherData là null
      task = _getItemsAndOutfits(null) // Truyền null
          .flatMap((data) => _getSuggestionFromAI(data, purpose: purpose));
    }
    return task.run();
  }

  // Helper function cho Bước 2, giờ nhận và trả về đúng kiểu
  TaskEither<Failure, (Map<String, dynamic>?, List<ClothingItem>, List<Outfit>)> 
      _getItemsAndOutfits(Map<String, dynamic>? weatherData) { // Chấp nhận weatherData có thể null
    return TaskEither.tryCatch(
      () async {
        final itemsEither = await _clothingItemRepo.getAllItems();
        final outfitsEither = await _outfitRepo.getOutfits();
        
        // Sử dụng getOrElse để ném lỗi nếu có Left, giúp code gọn hơn
        final allItems = itemsEither.getOrElse((l) => throw Exception(l.message));
        final allOutfits = outfitsEither.getOrElse((l) => throw Exception(l.message));

        return (weatherData, allItems, allOutfits);
      },
      // Bắt lỗi được ném ra và chuyển thành Failure
      (error, stackTrace) => GenericFailure(error.toString()),
    );
  }

  // Helper function cho Bước 3
  TaskEither<Failure, Map<String, dynamic>> _getSuggestionFromAI(
    (Map<String, dynamic>?, List<ClothingItem>, List<Outfit>) data, {String? purpose}
  ) {
    final (weatherData, allItems, allOutfits) = data;

    // --- BƯỚC XÁC THỰC (VALIDATION) ---
    // Thực hiện kiểm tra logic nghiệp vụ ở đây
    final topwearCount = allItems.where((item) => item.category.startsWith('category_tops')).length;
    final bottomwearCount = allItems.where((item) => item.category.startsWith('category_bottoms') || item.category.startsWith('category_dresses_jumpsuits')).length;
    
    // Nếu không đủ điều kiện, trả về một `Left` chứa `Failure` một cách tường minh.
    if (topwearCount < 3 || bottomwearCount < 3) {
      return TaskEither.left(const GenericFailure('GetOutfitSuggestion_error_notEnoughItems'));
    }

    // --- BƯỚC GỌI API ---
    // Nếu đã qua bước xác thực, tiếp tục với logic gọi AI trong một khối try-catch an toàn.
    return TaskEither.tryCatch(
      () async {
        final langCode = _prefs.getString('language_code') ?? 'en';
        final promptParts = PromptStrings.localized[langCode]!;
        // Gọi hàm `getUserProfile()` để lấy tất cả thông tin
        final profileData = await _settingsRepo.getUserProfile();

        final gender = profileData['gender'] as String?;
        final userStyle = profileData['style'] as String?;
        final favoriteColors = 'Any color';

        final setOutfits = allOutfits.where((o) => o.isFixed).toList();
        final fixedItemIds = setOutfits.expand((o) => o.itemIds.split(',')).toSet();
        final individualItems = allItems.where((item) => !fixedItemIds.contains(item.id)).toList();
        final unknownItemName = promptParts['prompt_part_unknown_item'] ?? 'Unknown Item';
        final setOutfitsString = setOutfits.map((outfit) => 
            '- ${promptParts['prompt_part_set']} "${outfit.name}": ${promptParts['prompt_part_includes']} [${outfit.itemIds.split(',').map((id) => allItems.firstWhere((item) => item.id == id, orElse: () => ClothingItem(id: '', name: unknownItemName, category: '', color: '', imagePath: '', closetId: '')).name).join(', ')}]').join('\n');

        final closetItemsString = individualItems.map((item) => 
            '- ${item.name} (${item.category}, ${promptParts['prompt_part_color']} ${item.color})').join('\n');

        final suggestionJsonEither = await _suggestionRepo.getOutfitSuggestion(
          weather: weatherData,
          cityName: weatherData?['name'] as String? ?? 'Unknown Location',
          gender: gender ?? '',
          userStyle: userStyle ?? '',
          favoriteColors: favoriteColors,
          setOutfitsString: setOutfitsString.isNotEmpty ? setOutfitsString : (promptParts['prompt_part_none'] ?? 'None'),
          closetItemsString: closetItemsString.isNotEmpty ? closetItemsString : (promptParts['prompt_part_none'] ?? 'None'),
          purpose: purpose,
        );

        final suggestionJson = suggestionJsonEither.getOrElse((l) => throw Exception(l.message));
        final compositionMap = suggestionJson['outfit_composition'] as Map<String, dynamic>? ?? {};
        final Map<String, ClothingItem?> structuredComposition = {};
        compositionMap.forEach((slot, itemName) {
            if (itemName != null) {
            final foundItem = allItems.cast<ClothingItem?>().firstWhere((item) => item?.name == itemName, orElse: () => null);
            structuredComposition[slot] = foundItem;
            } else {
            structuredComposition[slot] = null;
            }
        });
        final suggestionResult = SuggestionResult(
            outfitName: suggestionJson['outfit_name'] as String? ?? (promptParts['useCase_default_stylishOutfit'] ?? 'Stylish Outfit'),
            reason: suggestionJson['reason'] as String? ?? (promptParts['useCase_default_greatChoice'] ?? 'A great choice!'),
            composition: structuredComposition,
        );

        return {
          'weather': weatherData,
          'suggestionResult': suggestionResult,
        };
      },
      (error, stackTrace) => GenericFailure(error.toString()),
    );
  }
}