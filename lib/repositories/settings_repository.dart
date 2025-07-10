// lib/repositories/settings_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mincloset/providers/service_providers.dart';
import 'package:mincloset/utils/logger.dart'; // <<< THÊM IMPORT

class SettingsRepository {
  final Ref _ref;

  SettingsRepository(this._ref);

  // --- THỐNG NHẤT KHAI BÁO KEY ---
  // Sử dụng static const để đảm bảo các key này là duy nhất và không đổi.
  static const userNameKey = 'user_name';
  static const avatarPathKey = 'user_avatar_path';
  static const genderKey = 'user_gender';
  static const dobKey = 'user_dob';
  static const heightKey = 'user_height';                 // <<< THÊM MỚI
  static const weightKey = 'user_weight';                 // <<< THÊM MỚI
  static const personalStylesKey = 'user_personal_styles'; // <<< THÊM MỚI
  static const favoriteColorsKey = 'user_favorite_colors'; // <<< THÊM MỚI
  static const styleKey = 'user_style';
  static const currencyKey = 'user_currency';
  static const numberFormatKey = 'user_number_format';
  static const cityModeKey = 'city_mode';
  static const manualCityKey = 'manualCity';
  static const manualCityLatKey = 'manual_city_lat';
  static const manualCityLonKey = 'manual_city_lon';
  static const showWeatherImageKey = 'showWeatherImage';


  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final profileData = {
      userNameKey: prefs.getString(userNameKey),
      avatarPathKey: prefs.getString(avatarPathKey),
      genderKey: prefs.getString(genderKey),
      dobKey: prefs.getString(dobKey),
      heightKey: prefs.getInt(heightKey),
      weightKey: prefs.getInt(weightKey),
      personalStylesKey: prefs.getStringList(personalStylesKey),
      favoriteColorsKey: prefs.getStringList(favoriteColorsKey),
      styleKey: prefs.getString(styleKey),
      currencyKey: prefs.getString(currencyKey),
      numberFormatKey: prefs.getString(numberFormatKey),
      cityModeKey: prefs.getString(cityModeKey),
      manualCityKey: prefs.getString(manualCityKey),
      manualCityLatKey: prefs.getDouble(manualCityLatKey),
      manualCityLonKey: prefs.getDouble(manualCityLonKey),
      showWeatherImageKey: prefs.getBool(showWeatherImageKey),
    };

    // DEBUG: In ra dữ liệu đọc được
    logger.i("Reading user profile: $profileData");

    return profileData;
  }


  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    
    // DEBUG: In ra dữ liệu sắp được lưu
    logger.i("Saving user profile with data: $data");

    // Duyệt qua map dữ liệu và lưu vào SharedPreferences
    for (var entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) {
        await prefs.remove(key);
        logger.i("Removed key: $key");
      } else if (value is String) {
        await prefs.setString(key, value);
        logger.i("Saved String: $key = $value");
      } else if (value is bool) {
        await prefs.setBool(key, value);
        logger.i("Saved bool: $key = $value");
      } else if (value is double) {
        await prefs.setDouble(key, value);
        logger.i("Saved double: $key = $value");
      } else if (value is int) {
        await prefs.setInt(key, value);
        logger.i("Saved int: $key = $value");
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
        logger.i("Saved List<String>: $key = $value");
      }
    }
  }

  // Hàm này không còn cần thiết vì đã được tích hợp vào getUserProfile
  // Future<Map<String, String?>> getSuggestionInfo() async { ... }
}