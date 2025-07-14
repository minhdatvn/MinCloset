// lib/repositories/settings_repository.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const String userNameKey = 'user_name';
  static const String avatarPathKey = 'avatar_path';
  static const String genderKey = 'gender';
  static const String dobKey = 'dob';
  static const String heightKey = 'height';
  static const String weightKey = 'weight';
  static const String personalStylesKey = 'personal_styles';
  static const String favoriteColorsKey = 'favorite_colors';
  static const String cityModeKey = 'city_mode';
  static const String manualCityKey = 'manual_city';
  static const String manualCityLatKey = 'manual_city_lat';
  static const String manualCityLonKey = 'manual_city_lon';
  static const String showWeatherImageKey = 'show_weather_image';
  static const String showMascotKey = 'show_mascot';
  static const String currencyKey = 'currency';
  static const String numberFormatKey = 'number_format';
  static const String heightUnitKey = 'height_unit';
  static const String weightUnitKey = 'weight_unit';
  static const String tempUnitKey = 'temp_unit';
  static const String _userProfileKey = 'user_profile_data';

  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    // Đọc dữ liệu hồ sơ hiện có
    final existingProfileJson = _prefs.getString(_userProfileKey);
    final Map<String, dynamic> existingProfile =
        existingProfileJson != null ? json.decode(existingProfileJson) : {};

    // Hợp nhất dữ liệu mới vào dữ liệu hiện có
    existingProfile.addAll(data);

    // Lưu lại hồ sơ đã được hợp nhất
    await _prefs.setString(_userProfileKey, json.encode(existingProfile));
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final profileJson = _prefs.getString(_userProfileKey);
    if (profileJson != null) {
      return json.decode(profileJson) as Map<String, dynamic>;
    }
    return {}; // Trả về một map rỗng nếu không có dữ liệu
  }
}