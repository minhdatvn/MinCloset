// lib/domain/use_cases/get_outfit_suggestion_use_case.dart
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

class GetOutfitSuggestionUseCase {
  final ClothingItemRepository _clothingItemRepo;
  final WeatherRepository _weatherRepo;
  final SuggestionRepository _suggestionRepo;
  final OutfitRepository _outfitRepo;
  final SettingsRepository _settingsRepo;

  GetOutfitSuggestionUseCase(
    this._clothingItemRepo,
    this._weatherRepo,
    this._suggestionRepo,
    this._outfitRepo,
    this._settingsRepo
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
    final cityModeString = settings['cityMode'] as String? ?? 'auto';
    final cityMode = CityMode.values.byName(cityModeString);
    const defaultCity = 'Da Nang';

    if (cityMode == CityMode.manual) {
      // Đọc các giá trị lat/lon từ map `settings`
      final lat = settings[SettingsRepository.manualCityLatKey] as double?;
      final lon = settings['manual_city_lon'] as double?;

      if (lat != null && lon != null) {
        logger.i('Get weather by saved coordinates: ($lat, $lon)');
        final weatherData = await _weatherRepo.getWeatherByCoords(lat, lon);
        // Cập nhật lại tên thành phố để hiển thị đúng trên UI
        return weatherData.map((data) {
            data['name'] = settings['manualCity'] ?? defaultCity;
            return data;
        });
      } else {
        logger.w('Manual location data missing, reverting to default.');
        return _weatherRepo.getWeather(defaultCity);
      }
    } else { // Chế độ Auto-detect không thay đổi
      try {
        logger.i('Getting weather by auto-detecting location…');
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return const Left(GenericFailure('Location services are disabled. Please enable it in your device settings.'));
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return const Left(GenericFailure('Location permissions are denied. Please enable it for MinCloset in your device settings.'));
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
            weatherData['name'] = placemarks.first.administrativeArea ?? placemarks.first.locality ?? defaultCity;
            return Right(weatherData);
          },
        );
      } catch (e, s) {
        logger.e("Failed to get auto location, using default.", error: e, stackTrace: s);
        Sentry.captureException(e, stackTrace: s);
        return _weatherRepo.getWeather(defaultCity);
      }
    }
  }
  
  // Sửa lỗi `tryCatch` và kiểu trả về bằng cách dùng TaskEither đúng cách
  Future<Either<Failure, Map<String, dynamic>>> execute({String? purpose}) {
    // Bọc hàm bất đồng bộ trả về Either vào trong TaskEither
    final task = TaskEither(getWeatherForSuggestion)
    .flatMap(_getItemsAndOutfits)
    .flatMap((data) => _getSuggestionFromAI(data, purpose: purpose));    

    return task.run(); 
  }

  // Helper function cho Bước 2, giờ nhận và trả về đúng kiểu
  TaskEither<Failure, (Map<String, dynamic>, List<ClothingItem>, List<Outfit>)>
      _getItemsAndOutfits(Map<String, dynamic> weatherData) {
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
      (Map<String, dynamic>, List<ClothingItem>, List<Outfit>) data, {String? purpose}) {
        
    final (weatherData, allItems, allOutfits) = data;

    // --- BƯỚC XÁC THỰC (VALIDATION) ---
    // Thực hiện kiểm tra logic nghiệp vụ ở đây
    final topwearCount = allItems.where((item) => item.category.startsWith('Tops')).length;
    final bottomwearCount = allItems.where((item) => item.category.startsWith('Bottoms') || item.category.startsWith('Dresses/Jumpsuits')).length;
    
    // Nếu không đủ điều kiện, trả về một `Left` chứa `Failure` một cách tường minh.
    if (topwearCount < 3 || bottomwearCount < 3) {
      return TaskEither.left(const GenericFailure('Please add at least 3 tops and 3 bottoms/skirts to your closet to receive suggestions.'));
    }

    // --- BƯỚC GỌI API ---
    // Nếu đã qua bước xác thực, tiếp tục với logic gọi AI trong một khối try-catch an toàn.
    return TaskEither.tryCatch(
      () async {
        // Gọi hàm `getUserProfile()` để lấy tất cả thông tin
        final profileData = await _settingsRepo.getUserProfile();
        // Lấy các giá trị cần thiết từ map trả về
        final gender = profileData['gender'] as String? ?? 'Not specified';
        final userStyle = profileData['style'] as String? ?? 'Any style';
        // --- KẾT THÚC SỬA LỖI ---
        final favoriteColors = 'Any color'; // Giữ nguyên hoặc lấy từ repo nếu có

        // ... logic còn lại không đổi ...
        final setOutfits = allOutfits.where((o) => o.isFixed).toList();
        final fixedItemIds = setOutfits.expand((o) => o.itemIds.split(',')).toSet();
        final individualItems = allItems.where((item) => !fixedItemIds.contains(item.id)).toList();
        
        final setOutfitsString = setOutfits.map((outfit) => '- Set "${outfit.name}": Gồm [${outfit.itemIds.split(',').map((id) => allItems.firstWhere((item) => item.id == id, orElse: () => ClothingItem(id: '', name: 'Unknown Item', category: '', color: '', imagePath: '', closetId: '')).name).join(', ')}]').join('\n');
        final closetItemsString = individualItems.map((item) => '- ${item.name} (${item.category}, màu ${item.color})').join('\n');

        final suggestionJsonEither = await _suggestionRepo.getOutfitSuggestion(
          weather: weatherData,
          cityName: weatherData['name'] as String,
          gender: gender,
          userStyle: userStyle,
          favoriteColors: favoriteColors,
          setOutfitsString: setOutfitsString.isNotEmpty ? setOutfitsString : "Không có",
          closetItemsString: closetItemsString.isNotEmpty ? closetItemsString : "Không có",
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
            outfitName: suggestionJson['outfit_name'] as String? ?? 'Stylish Outfit',
            reason: suggestionJson['reason'] as String? ?? 'A great choice for today!',
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